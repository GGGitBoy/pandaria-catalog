#!/bin/bash
#
# Common functions for PostgreSQL

# @description Activate nss_wrapper configuration for the PostgreSQL server,
#   allowing to perform certain actions with arbitrary non-root users.
postgresql_activate_nss_wrapper() {
    local uid
    uid="$(id -u)"
    if ! getent passwd "$(id -u)" &>/dev/null; then
        local wrapper_candidate wrapper passwd_file group_file gid
        for wrapper_candidate in {/usr,}/lib*{/*,}/libnss_wrapper.so; do
            [[ -s $wrapper_candidate ]] && wrapper="$wrapper_candidate"
        done
        if [[ -z ${wrapper:-} ]]; then
            log "Could not find libnss_wrapper.so"
            return 1
        fi
        export LD_PRELOAD="$wrapper"
        # Create passwd and group files
        gid="$(id -g)"
        passwd_file="$(mktemp)"
        printf "%s:x:%s:%s:PostgreSQL:%s:/bin/false\n" \
            "postgres" "$uid" "$gid" "$PGDATA" >"$passwd_file"
        export NSS_WRAPPER_PASSWD="$passwd_file"
        group_file="$(mktemp)"
        printf "%s:x:%s:\n" "postgres" "$gid" "$gid" "$PGDATA" >"$group_file"
        export NSS_WRAPPER_GROUP="$group_file"
    fi
}

# @description Deactivate the nss_wrapper configuration.
postgresql_deactivate_nss_wrapper() {
    if [[ ${LD_PRELOAD:-} == */libnss_wrapper.so ]]; then
        unset LD_PRELOAD
        if [[ -n ${NSS_WRAPPER_PASSWD:-} ]]; then
            rm -f "$NSS_WRAPPER_PASSWD"
            unset NSS_WRAPPER_PASSWD
        fi
        if [[ -n ${NSS_WRAPPER_GROUP:-} ]]; then
            rm -f "$NSS_WRAPPER_GROUP"
            unset NSS_WRAPPER_GROUP
        fi
    fi
}

# @description Create a new `pg_hba.conf` file with the default host auth
#   method specified as the first argument.
#
# @arg $1 The default host auth method to use.
postgresql_create_pg_hba_conf() {
    local auth_method="$1"
    local pg_hba_conf="$PGDATA/pg_hba.conf"
    local pg_hba_conf_temp="$pg_hba_conf.temp"
    # Preserve the configuration file only until the table header line
    while read -r line; do
        echo "$line"
        [[ $line == "# TYPE"* ]] && break
    done <"$pg_hba_conf" >"$pg_hba_conf_temp"
    # The rest of the config file will be overwritten
    cat >"$pg_hba_conf_temp" <<EOF
# Allow remote connections for all users.
# "local" is for Unix domain socket connections only
local   all             all                                     $auth_method
# IPv4 local connections:
host    all             all             0.0.0.0/0               $auth_method
# IPv6 local connections:
host    all             all             ::/0                    $auth_method
# Allow replication connections by a user with the replication privilege.
host    replication     all             0.0.0.0/0               $auth_method
host    replication     all             ::/0                    $auth_method
EOF
    # Replace the config file
    cp "$pg_hba_conf_temp" "$pg_hba_conf"
    rm "$pg_hba_conf_temp"
}

# @description Append SSL/TLS configuration to the `pg_hba.conf` configuration
#   file.
#
# @arg $1 The default host auth method to use.
postgresql_append_ssl_config_to_pg_hba_conf() {
    local auth_method="$1"
    cat >>"$PGDATA/pg_hba.conf" <<EOF
# Allow remote connections made with SSL/TLS encryption.
hostssl all             all             0.0.0.0/0               $auth_method
hostssl all             all             ::/0                    $auth_method
EOF
}

# @description Execute the PostgreSQL `psql` command-line interface.
#   The parameters provided as arguments to this function will be added to the
#   `psql` command-line call.
postgresql_exec_psql() {
    psql --no-password --no-psqlrc --set ON_ERROR_STOP=1 "$@"
}

# @description Start a local instance of the PostgreSQL server. This is useful
#   for performing initial configurations of the server.
postgresql_start_local() {
    log "Starting PostgreSQL server for initial configuration"
    pg_ctl -o "-c listen_addresses=''" -w start
}

# @description Stop the PostgreSQL server.
postgresql_stop() {
    log "Stopping PostgreSQL"
    pg_ctl -m fast -w stop
}

# @description Create an initial user, defined via environment variables.
postgresql_create_initial_user() {
    log "Creating initial user $_POSTGRES_INITIAL_USERNAME"
    postgresql_exec_psql --dbname postgres <<EOF
DO
\$do\$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_catalog.pg_roles
        WHERE rolname = '$_POSTGRES_INITIAL_USERNAME'
    ) THEN
        CREATE ROLE "$_POSTGRES_INITIAL_USERNAME"
        LOGIN PASSWORD '$_POSTGRES_INITIAL_PASSWORD';
    END IF;
END
\$do\$;
EOF
}

# @description Create an initial database, defined via environment variables.
postgresql_create_initial_database() {
    log "Creating initial database $_POSTGRES_INITIAL_DATABASE"
    postgresql_exec_psql --dbname postgres <<EOF
SELECT 'CREATE DATABASE "$_POSTGRES_INITIAL_DATABASE"'
WHERE NOT EXISTS (
    SELECT FROM pg_database
    WHERE datname = '$_POSTGRES_INITIAL_DATABASE'
)\gexec
EOF
}

# @description Grant the initial database permissions for the new user.
postgresql_grant_initial_database_permissions() {
    log "Granting ownership to user for database $_POSTGRES_INITIAL_DATABASE"
    postgresql_exec_psql --dbname postgres \
        --set db="$_POSTGRES_INITIAL_DATABASE" \
        --set user="$_POSTGRES_INITIAL_USERNAME" <<"EOF"
GRANT ALL PRIVILEGES ON DATABASE :"db" TO :"user";
ALTER DATABASE :"db" OWNER TO :"user";
EOF
}

# @description Check whether the current PostgreSQL node is a primary or not.
#
# @exitcode 0 If the current PostgreSQL node is a primary node.
# @exitcode 1 If the current PostgreSQL node is NOT a primary node.
postgresql_is_primary() {
    [[ $_POSTGRES_PRIMARY_HOST == "$HOSTNAME."* ]]
}

# @description Create the replication user, defined via environment variables.
postgresql_create_replication_user() {
    log "Creating replication user $_POSTGRES_REPLICATION_USERNAME"
    postgresql_exec_psql --dbname postgres <<EOF
CREATE ROLE "$_POSTGRES_REPLICATION_USERNAME"
REPLICATION LOGIN PASSWORD '$_POSTGRES_REPLICATION_PASSWORD';
EOF
}

# @description Execute a PostgreSQL command within the environment of a
#   replication node. This environment includes specific values for the
#   `PGHOST`, `PGUSER` and `PGPASSWORD` environment variables.
postgresql_replication_env() {
    env PGHOST="$_POSTGRES_PRIMARY_HOST" \
        PGUSER="$_POSTGRES_REPLICATION_USERNAME" \
        PGPASSWORD="$_POSTGRES_REPLICATION_PASSWORD" \
        "$@"
}

# @description Wait for the primary node to be accessible, and clone it.
#   In case of any errors, each step will be retried.
postgresql_clone_primary() {
    local attempt=0
    local max_attempts="$_POSTGRES_REPLICA_TO_PRIMARY_CONNECTION_ATTEMPTS"
    while ! postgresql_replication_env pg_isready --dbname="postgres"; do
        if (( attempt++ >= max_attempts )); then
            log "Failed to access primary node after $max_attempts attempts"
            exit 1
        fi
        sleep 1
    done
    log "Cloning primary node"
    attempt=0
    max_attempts="$_POSTGRES_REPLICA_TO_PRIMARY_CLONE_ATTEMPTS"
    while ! postgresql_replication_env pg_basebackup \
        --pgdata="$PGDATA" \
        --wal-method=stream \
        --write-recovery-conf; do
        if (( attempt++ >= max_attempts )); then
            log "Failed to clone primary node after $max_attempts attempts"
            exit 1
        fi
        sleep 1
    done
}

# @description Set a configuration in PostgreSQL's configuration file.
#
# @arg $1 string The configuration entry to set.
# @arg $1 string The value to set for the configuration entry.
postgresql_conf_set() {
    local entry_name="$1"
    local entry_value="$2"
    local entry="$entry_name = '$entry_value'"
    # Replace the entry in the file without the 'sed' command-line tool
    local postgresql_conf="$PGDATA/postgresql.conf"
    local postgresql_conf_temp="$postgresql_conf.temp"
    local entry_regexp="^#?\s*$entry_name\s*="
    local match_found=false
    log "Setting $entry_name in $postgresql_conf"
    while read -r line; do
        if [[ $line =~ $entry_regexp ]]; then
            match_found=true
            echo "$entry"
        else
            echo "$line"
        fi
    done <"$postgresql_conf" >"$postgresql_conf_temp"
    # Append to the file if the entry was not found
    if ! "$match_found"; then
        log "Entry not found in configuration, it will be appended"
        echo "$entry" >>"$postgresql_conf_temp"
    fi
    # Replace the config file
    cp "$postgresql_conf_temp" "$postgresql_conf"
    rm "$postgresql_conf_temp"
}

# @description Execute all scripts to initialize the PostgreSQL database.
#   These scripts will be located at the `/docker-entrypoint-initdb.d` folder.
postgresql_execute_initdb_scripts() {
    for initdb_script in /docker-entrypoint-initdb.d/*; do
        if [[ $initdb_script == "/docker-entrypoint-initdb.d/*" ]]; then
            log "No init scripts were mounted at /docker-entrypoint-initdb.d"
            return
        fi
        case "$initdb_script" in
            *.sh)
                if [[ -x "$initdb_script" ]]; then
                    log "Executing init script: $initdb_script"
                    "$initdb_script"
                else
                    log "Sourcing init script: $initdb_script"
                    # shellcheck disable=SC1090
                    . "$initdb_script"
                fi
                ;;
            *.sql)
                log "Executing init script: $initdb_script"
                postgresql_exec_psql -f "$initdb_script"
                ;;
            *.sql.gz)
                log "Executing init script: $initdb_script"
                gunzip -c "$initdb_script" | postgresql_exec_psql
                ;;
            *.sql.xz)
                log "Executing init script: $initdb_script"
                xzcat "$initdb_script" | postgresql_exec_psql
                ;;
            *.sql.zst)
                log "Executing init script: $initdb_script"
                zstd -dc "$initdb_script" | postgresql_exec_psql
                ;;
            *)
                log "Ignoring init script: $initdb_script"
                ;;
        esac
    done
}

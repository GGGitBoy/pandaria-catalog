#!/bin/bash
#
# Entrypoint for PostgreSQL container images

# Strict mode
set -euo pipefail

# Load functions used by the script
# shellcheck disable=SC1091
. /mnt/postgresql/scripts/functions.sh
# shellcheck disable=SC1091
. /mnt/postgresql/scripts/postgresql-functions.sh

# The PG_VERSION file is expected to exist in already initialized environments
if [[ ! -s $PGDATA/PG_VERSION ]]; then
    # Initialize database directory
    if postgresql_is_primary; then
        log "Initializing database directory for primary node"
        postgresql_activate_nss_wrapper
        initdb --username="$PGUSER" --pwfile=<(printf '%s\n' "$PGPASSWORD")
        postgresql_deactivate_nss_wrapper
    else
        log "Cloning primary node"
        postgresql_clone_primary
    fi
    # Copy mounted configuration files, if they exist
    if [[ -n ${_POSTGRES_CONF_FILE:-} && -e $_POSTGRES_CONF_FILE ]]; then
        log "Copying mounted postgresql.conf to $PGDATA"
        cp "$_POSTGRES_CONF_FILE" "$PGDATA/postgresql.conf"
    else
        # SSL/TLS
        if [[ ${_POSTGRES_SSL:-} == "on" ]]; then
            [[ -n ${_POSTGRES_SSL:-} ]] && \
                postgresql_conf_set ssl "$_POSTGRES_SSL"
            [[ -n ${_POSTGRES_SSL_CA_FILE:-} ]] && \
                postgresql_conf_set ssl_ca_file "$_POSTGRES_SSL_CA_FILE"
            [[ -n ${_POSTGRES_SSL_CERT_FILE:-} ]] && \
                postgresql_conf_set ssl_cert_file "$_POSTGRES_SSL_CERT_FILE"
            [[ -n ${_POSTGRES_SSL_CRL_FILE:-} ]] && \
                postgresql_conf_set ssl_crl_file "$_POSTGRES_SSL_CRL_FILE"
            [[ -n ${_POSTGRES_SSL_KEY_FILE:-} ]] && \
                postgresql_conf_set ssl_key_file "$_POSTGRES_SSL_KEY_FILE"
        fi
        # Replication parameters
        if ! postgresql_is_primary; then
            # Configure recovery
            postgresql_conf_set \
                primary_conninfo "\
host=$_POSTGRES_PRIMARY_HOST \
port=$PGPORT \
user=$_POSTGRES_REPLICATION_USERNAME \
password=$_POSTGRES_REPLICATION_PASSWORD \
application_name=$_POSTGRES_CLUSTER_APPLICATION_NAME"
        fi
    fi
    if [[ -n ${_POSTGRES_HBA_CONF_FILE:-}
        && -e $_POSTGRES_HBA_CONF_FILE ]]; then
        log "Copying mounted pg_hba.conf to $PGDATA"
        cp "$_POSTGRES_HBA_CONF_FILE" "$PGDATA/pg_hba.conf"
    else
        log "Enabling password-based authentication"
        : "${_POSTGRES_HOST_AUTH_METHOD:="$(postgres -C password_encryption)"}"
        postgresql_create_pg_hba_conf "$_POSTGRES_HOST_AUTH_METHOD"
        # SSL/TLS
        if [[ ${_POSTGRES_SSL:-} == on
            && -n ${_POSTGRES_SSL_CA_FILE:-} ]]; then
            SSL_AUTH_METHOD="cert"
            if [[ ${_POSTGRES_SSL_MODE:-} == "verify-"* ]]; then
                SSL_AUTH_METHOD+=" clientcert=$_POSTGRES_SSL_MODE"
            fi
            postgresql_append_ssl_config_to_pg_hba_conf "$SSL_AUTH_METHOD"
        fi
    fi
    if [[ -n ${_POSTGRES_IDENT_CONF_FILE:-}
        && -e $_POSTGRES_IDENT_CONF_FILE ]]; then
        log "Copying mounted pg_ident.conf to $PGDATA"
        cp "$_POSTGRES_IDENT_CONF_FILE" "$PGDATA/pg_ident.conf"
    fi
    # Start PostgreSQL, create users and initialize the databases, then stop
    # This should only happen in the primary node
    if postgresql_is_primary; then
        postgresql_start_local
        if [[ -n ${_POSTGRES_INITIAL_USERNAME:-} ]]; then
            postgresql_create_initial_user
        fi
        if [[ -n ${_POSTGRES_INITIAL_DATABASE:-} ]]; then
            postgresql_create_initial_database
            if [[ -n ${_POSTGRES_INITIAL_USERNAME:-} ]]; then
                postgresql_grant_initial_database_permissions
            fi
        fi
        if [[ -n ${_POSTGRES_REPLICATION_USERNAME:-} ]]; then
            postgresql_create_replication_user
        fi
        postgresql_execute_initdb_scripts
        postgresql_stop
    fi
fi

log "Starting PostgreSQL"
exec postgres

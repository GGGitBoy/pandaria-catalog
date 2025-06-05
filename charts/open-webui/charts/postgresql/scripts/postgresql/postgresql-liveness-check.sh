#!/bin/bash
#
# Liveness check script for PostgreSQL containers

# Strict mode
set -euo pipefail

exec pg_isready

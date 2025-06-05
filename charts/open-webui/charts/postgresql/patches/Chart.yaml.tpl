#!BuildTag: postgresql:${VERSION}-%RELEASE%
#!BuildTag: postgresql:${VERSION}
annotations:
  helm.sh/images: |
    - image: ${CONTAINER_REGISTRY}/containers/postgresql:${APP_VERSION}
      name: postgresql
    - image: ${CONTAINER_REGISTRY}/containers/postgres-exporter:0
      name: postgres-exporter
    - image: ${CONTAINER_REGISTRY}/containers/bci-busybox:15.6
      name: bci-busybox
apiVersion: v2
appVersion: "${APP_VERSION}"
description: PostgreSQL is an advanced object-relational database management system that supports an extended subset of the SQL standard, including transactions, foreign keys, subqueries, triggers, user-defined types and functions.
home: https://apps.rancher.io/applications/postgresql
icon: https://apps.rancher.io/logos/postgresql.png
maintainers:
  - name: SUSE LLC
    url: https://www.suse.com/
name: postgresql
version: ${VERSION}

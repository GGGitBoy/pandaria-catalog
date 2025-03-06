#!BuildTag: ztunnel:${VERSION}-%RELEASE%
#!BuildTag: ztunnel:${VERSION}
annotations:
  helm.sh/images: |
    - image: ${CONTAINER_REGISTRY}/containers/ztunnel:${APP_VERSION}
      name: ztunnel
apiVersion: v2
appVersion: ${APP_VERSION}
description: Helm chart for istio ztunnel components
icon: https://apps.rancher.io/logos/istio.png
keywords:
  - istio-ztunnel
  - istio
maintainers:
  - name: SUSE LLC
    url: https://www.suse.com/
name: ztunnel
version: ${VERSION}

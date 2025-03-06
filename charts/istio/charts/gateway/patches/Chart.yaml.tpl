#!BuildTag: gateway:${VERSION}-%RELEASE%
#!BuildTag: gateway:${VERSION}
annotations:
  helm.sh/images: |
    - image: ${CONTAINER_REGISTRY}/containers/proxyv2:${APP_VERSION}
      name: proxyv2
apiVersion: v2
appVersion: ${APP_VERSION}
description: Helm chart for deploying Istio gateways
icon: https://apps.rancher.io/logos/istio.png
keywords:
  - istio
  - gateways
maintainers:
  - name: SUSE LLC
    url: https://www.suse.com/
name: gateway
version: ${VERSION}

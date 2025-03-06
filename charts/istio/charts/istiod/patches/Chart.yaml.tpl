#!BuildTag: istiod:${VERSION}-%RELEASE%
#!BuildTag: istiod:${VERSION}
annotations:
  helm.sh/images: |
    - image: ${CONTAINER_REGISTRY}/containers/pilot:${APP_VERSION}
      name: pilot
    - image: ${CONTAINER_REGISTRY}/containers/proxyv2:${APP_VERSION}
      name: proxyv2
    - image: ${CONTAINER_REGISTRY}/containers/bci-busybox:15.6
      name: bci-busybox
apiVersion: v2
appVersion: ${APP_VERSION}
description: Helm chart for istio control plane
icon: https://apps.rancher.io/logos/istio.png
keywords:
  - istio
  - istiod
  - istio-discovery
maintainers:
  - name: SUSE LLC
    url: https://www.suse.com/
name: istiod
version: ${VERSION}

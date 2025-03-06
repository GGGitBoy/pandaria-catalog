#!BuildTag: cni:${VERSION}-%RELEASE%
#!BuildTag: cni:${VERSION}
annotations:
  helm.sh/images: |
    - image: ${CONTAINER_REGISTRY}/containers/install-cni:${APP_VERSION}
      name: install-cni
apiVersion: v2
appVersion: ${APP_VERSION}
description: Helm chart for istio-cni components
icon: https://apps.rancher.io/logos/istio.png
keywords:
  - istio-cni
  - istio
maintainers:
  - name: SUSE LLC
    url: https://www.suse.com/
name: cni
version: ${VERSION}

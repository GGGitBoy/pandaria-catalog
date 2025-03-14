#!BuildTag: kiali:${VERSION}-%RELEASE%
#!BuildTag: kiali:${VERSION}
annotations:
  helm.sh/images: |
    - image: ${CONTAINER_REGISTRY}/containers/kiali:${APP_VERSION}
      name: kiali
apiVersion: v2
appVersion: ${APP_VERSION}
description: Kiali is a management console for Istio service mesh. Kiali can be quickly installed as an Istio add-on or integrated as a trusted component within a production environment.
home: https://apps.rancher.io/applications/kiali
icon: https://apps.rancher.io/logos/kiali.png
keywords:
  - istio
  - kiali
maintainers:
  - name: SUSE LLC
    url: https://www.suse.com/
name: kiali
version: ${VERSION}

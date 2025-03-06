#!BuildTag: istio:${VERSION}-%RELEASE%
#!BuildTag: istio:${VERSION}
annotations:
  helm.sh/images: |
    - image: ${CONTAINER_REGISTRY}/containers/install-cni:${APP_VERSION}
      name: install-cni
    - image: ${CONTAINER_REGISTRY}/containers/pilot:${APP_VERSION}
      name: pilot
    - image: ${CONTAINER_REGISTRY}/containers/proxyv2:${APP_VERSION}
      name: proxyv2
    - image: ${CONTAINER_REGISTRY}/containers/ztunnel:${APP_VERSION}
      name: ztunnel
    - image: ${CONTAINER_REGISTRY}/containers/bci-busybox:15.6
      name: bci-busybox
apiVersion: v2
appVersion: ${APP_VERSION}
description: Istio is an open source service mesh that layers transparently onto existing distributed applications. Istio’s powerful features provide a uniform and more efficient way to secure, connect, and monitor services. Istio is the path to load balancing, service-to-service authentication, and monitoring – with few or no service code changes.
dependencies:
  - condition: base.enabled
    name: base
    version: 1.x.x
  - condition: cni.enabled
    name: cni
    version: 1.x.x
  - condition: gateway.enabled
    name: gateway
    version: 1.x.x
  - condition: istiod.enabled
    name: istiod
    version: 1.x.x
  - condition: ztunnel.enabled
    name: ztunnel
    version: 1.x.x
home: https://apps.rancher.io/applications/istio
icon: https://apps.rancher.io/logos/istio.png
keywords:
  - istio
maintainers:
  - name: SUSE LLC
    url: https://www.suse.com/
name: istio
version: ${VERSION}

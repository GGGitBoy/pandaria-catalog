_internal_defaults_do_not_set:
  hub: ${CONTAINER_REGISTRY}
  tag: ${APP_VERSION}
  image: containers/pilot

  global:
    # -- Global override for container image registry
    imageRegistry: ""

    hub: ${CONTAINER_REGISTRY}
    tag: ${APP_VERSION}
    proxy:
      hub: ${CONTAINER_REGISTRY}
      image: containers/proxyv2
      tag: ${APP_VERSION}
    proxy_init:
      hub: ${CONTAINER_REGISTRY}
      image: containers/proxyv2
      tag: ${APP_VERSION}
    grpc_init:
      hub: ${CONTAINER_REGISTRY}
      image: containers/bci-busybox
      tag: 15.6

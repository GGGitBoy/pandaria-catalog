_internal_defaults_do_not_set:
  hub: ${CONTAINER_REGISTRY}
  tag: ${APP_VERSION}
  image: containers/install-cni

  global:
    # -- Global override for container image registry
    imageRegistry: ""

    hub: ${CONTAINER_REGISTRY}
    tag: ${APP_VERSION}

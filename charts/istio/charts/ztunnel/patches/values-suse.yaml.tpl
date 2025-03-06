_internal_defaults_do_not_set:
  global:
    # -- Global override for container image registry
    imageRegistry: ""
    # -- Global override for container image registry pull secrets
    imagePullSecrets: []

  hub: ${CONTAINER_REGISTRY}
  tag: ${APP_VERSION}
  image: containers/ztunnel

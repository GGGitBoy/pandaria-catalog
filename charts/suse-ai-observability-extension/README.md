# SUSE AI Observability Extension Helm Chart

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.2](https://img.shields.io/badge/AppVersion-1.0.2-informational?style=flat-square)

SUSE AI Observability Extension provides AI specific dashboards in the SUSE Observability product. The extension receives data from workloads instrumented with [OpenLIT SDK](https://github.com/openlit/openlit/tree/main/sdk/python). OpenLIT is a monitoring framework built on top of OpenTelemetry that gives you complete Observability for your AI stack, from LLMs to vector databases and GPUs, with just one line of code with tracing and metrics.


## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| SUSE LLC |  | <https://www.suse.com> |

## Requirements

- Kubernetes: `>= 1.21`  
- Helm: `>= 3.7.0`  

## Deploying SUSE AI Observability Extension Chart

### Premises

- You already have SUSE Observability installed in your cluster and are able to access the web interface.
- You have installed the Kubernetes and the Open Telemtry StackPacks.
- The observed AI cluster has the SUSE Observability Agent running.

### Install SUSE AI Observability Extension

- Retrieve your CLI API token in the SUSE Observability web interface.

- Create secret for the application collection in the namespace where the extension will be installed:

    ```bash
    kubectl create namespace so-extensions

    kubectl create secret docker-registry application-collection \
    --docker-server=dp.apps.rancher.io \
    --docker-username=APPCO_USERNAME \
    --docker-password=APPCO_USER_TOKEN \
    -n so-extensions

    helm registry login dp.apps.rancher.io/charts \
      -u APPCO_USERNAME \
      -p APPCO_USER_TOKEN
    ```

- Create a minimal `genai-values.yaml` file with the following content:

    ``` yaml
    global:
      imagePullSecrets:
      - application-collection
    serverUrl:  https://xxx      # SUSE Observability URL. Installing this Chart along SUSE Observability allows you to use http://suse-observability-router.suse-observability.svc.cluster.local:8080
    apiKey: xxx                  # SUSE Observability API Key
    apiToken: xxx                # SUSE Observability CLI Token
    clusterName: xxx             # Cluster name as defined for the Kubernetes StackPack instance in SUSE Observability

    ```

- Install SUSE AI Observability Extension. Assuming that the release name is `ai-obs`:

    ```bash
    helm upgrade --install --namespace so-extensions --create-namespace -f genai_values.yaml ai-obs oci://dp.apps.rancher.io/charts/suse-ai-observability-extension
    ```

## Uninstalling SUSE AI Observability Extension Chart

To uninstall/delete the `ai-obs` release:

```bash
helm uninstall ai-obs -n so-extensions
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| apiKey | string | `""` | SUSE Observability API Key |
| apiToken | string | `""` | SUSE Observability CLI Token |
| clusterName | string | `""` | Cluster name as defined for the Kubernetes StackPack instance in SUSE Observability |
| fullnameOverride | string | `""` | String to fully override template |
| global.imagePullSecrets | list | `[]` | Global override for container image registry pull secrets |
| global.imageRegistry | string | `""` | Global override for container image registry |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy to use for the suse-ai-observability-extension-runtime container |
| image.registry | string | `"dp.apps.rancher.io"` | Image registry to use for the suse-ai-observability-extension-runtime container       |
| image.repository | string | `"containers/suse-ai-observability-extension-runtime"` | Image repository to use for the suse-ai-observability-extension-runtime container |
| image.tag | string | `"1.0.2"` | Image tag to use for the suse-ai-observability-extension-runtime container |
| setupImage.pullPolicy | string | `"IfNotPresent"` | Image pull policy to use for the suse-ai-observability-extension-setup container |
| setupImage.registry | string | `"dp.apps.rancher.io"` | Image registry to use for the suse-ai-observability-extension-setup container       |
| setupImage.repository | string | `"containers/suse-ai-observability-extension-setup"` | Image repository to use for the suse-ai-observability-extension-setup container |
| setupImage.tag | string | `"1.0.2"` | Image tag to use for the suse-ai-observability-extension-setup container |
| nameOverride | string | `""` | String to partially override template  (will maintain the release name) |
| podAnnotations | object | `{}` | Map of annotations to add to the pods |
| podLabels | object | `{}` | Map of labels to add to the pods |
| podSecurityContext | object | `{}` | Pod Security Context |
| resources | object | `{}` |  |
| schedule | string | `"*/5 * * * *"` | Schedule of the cron job |
| serverUrl | string | `""` | SUSE Observability URL |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |

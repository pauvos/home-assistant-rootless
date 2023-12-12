# Home Assistant (rootless)

[![Build docker image](https://github.com/pauvos/home-assistant-rootless/actions/workflows/build-image.yml/badge.svg)](https://github.com/pauvos/home-assistant-rootless/actions/workflows/build-image.yml)

Builds a [home-assistant/core](https://github.com/home-assistant/core) docker image **without s6 proceess manager** but with all **pip dependencies pre-installed**.

## Why?

The original home assistant docker image is a PITA if you try to run it in kubernetes: it requires root privileges and downloads pip dependencies on first startup.

I only use deconz and some other web-based integrations so I don't have the requirement to mount bluetooth/usb hardware directly to the container.

If you don't use kubernetes, you can obtain the official docker image here:
* [Docker Hub](https://hub.docker.com/r/homeassistant/home-assistant)
* [Github](https://github.com/home-assistant/core/pkgs/container/home-assistant)

## How to use

You can deploy home-assistant to kubernetes with the awesome multi-purpose [stakater/application](https://github.com/stakater/application) helm chart.

Example values.yaml:

```yaml
applicationName: home-assistant

configMap:
  enabled: true
  files:
    automations:
      automations.yaml: |
        ... some automations ...
    config:
      configuration.yaml: |
        ... the config ...
    media:
      media.yaml: |
        ... e.g. custom definitions for voice assistant ...

secret:
  enabled: true
  files:
    secrets:
      data:
        secrets.yaml: |
          psql_string: postgresql://homeassistant:TheSecretPassword@postgresql.postgresql.svc/homeassistant

deployment:
  strategy:
    type: Recreate
  image:
    repository: ghcr.io/pauvos/home-assistant-rootless
    tag: latest
    pullPolicy: Always
  args:
    - /srv/homeassistant/bin/hass
    - --skip-pip
    - --log-file
    - /dev/null
  env:
    TZ:
      value: Berlin/Europe
  ports:
    - containerPort: 8123
      name: http
      protocol: TCP
  resources:
    requests:
      cpu: '0.01'
      memory: 400Mi
    limits:
      cpu: '1'
      memory: 1Gi
  containerSecurityContext:
    allowPrivilegeEscalation: false
    capabilities:
      drop: [ALL]
    runAsUser: 999
    runAsGroup: 999
  securityContext:
    fsGroup: 999
    seccompProfile:
      type: RuntimeDefault
  volumes:
    automations:
      configMap:
        name: home-assistant-automations
    config:
      configMap:
        name: home-assistant-config
    media:
      configMap:
        name: home-assistant-media
    secrets:
      secret:
        secretName: home-assistant-secrets
    tmp:
      emptyDir:
        sizeLimit: 100Mi
  volumeMounts:
    automations:
      mountPath: /home/homeassistant/.homeassistant/automations/automations.yaml
      subPath: automations.yaml
    config:
      mountPath: /home/homeassistant/.homeassistant/configuration.yaml
      subPath: configuration.yaml
    media:
      mountPath: /home/homeassistant/.homeassistant/custom_sentences/de/media.yaml
      subPath: media.yaml
    secrets:
      mountPath: /home/homeassistant/.homeassistant/secrets.yaml
      subPath: secrets.yaml
    tmp:
      mountPath: /tmp

rbac:
  enabled: true
  serviceAccount:
    enabled: true

service:
  ports:
    - port: 8123
      name: http
      protocol: TCP
      targetPort: 8123

persistence:
  enabled: true
  mountPVC: true
  mountPath: /home/homeassistant/.homeassistant/
  storageSize: 1Gi
```

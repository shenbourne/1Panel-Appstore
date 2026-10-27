# Clash-Configurator for 1Panel

Visually create, edit, import and export Clash configurations, including nodes, proxy groups, DNS and rule sets. This editor does not run the Clash proxy core.

## Image and requirements

- Upstream: <https://github.com/shenbourne/Clash-Configurator>
- Image: `shenbourne/clash-configurator:latest` on Docker Hub.
- Published architectures: amd64, checked against the current Docker Hub `latest` manifest; attestation-only `unknown/unknown` entries are excluded.
- Container port: `3000`; default host port: `3001`.
- Requires the external Docker network `1panel-network`.

`latest` is mutable. Back up data and review upstream changes before upgrading.

## Installation and access

Sync this store, refresh local applications in 1Panel, and install the app. Set `PANEL_APP_PORT_HTTP` and `APP_BIND_IP` as needed.

The default binding is `127.0.0.1:3001`. Use it on the server or configure a protected 1Panel reverse proxy. For trusted LAN access, change `APP_BIND_IP` to the server IPv4 address or `0.0.0.0`.

Set `CORS_ORIGIN` to the actual browser origin, including scheme and port, without a path. Its default is `http://localhost:3001`; multiple origins can be comma-separated. CORS is not authentication and does not protect write APIs. Use a trusted network or an authenticated reverse proxy.

## Persistence and backup

- `./data/configs` → `/app/server/data/configs`: configurations.
- `./data/rule-sets` → `/app/server/data/rule-sets`: rule sets.
- `./data/temp` → `/app/server/data/temp`: temporary files.

Stop the app and back up its installed `data` directory. Configurations may contain proxy credentials.

## Icon source

The upstream repository has no reusable application logo. The temporary icon is the author's public GitHub avatar, not a mihomo logo.

## Verification scope

Upstream deployment files, published image architectures, package structure, forms and Compose variables have been checked. Actual 1Panel installation, image pulls and runtime behavior still require verification on the target server.

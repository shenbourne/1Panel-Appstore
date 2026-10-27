# Tool-Nest for 1Panel

A bilingual workspace for text, data conversion, images, PDFs, audio/video and network diagnostics. Some features download resources or contact external services.

## Image and requirements

- Upstream: <https://github.com/shenbourne/Tool-Nest>
- Image: `shenbourne/tool-nest:latest` on Docker Hub.
- Published architectures: amd64 / arm64, checked against the current Docker Hub `latest` manifest; attestation-only `unknown/unknown` entries are excluded.
- Container port: `3000`; default host port: `8080`.
- Requires the external Docker network `1panel-network`.

`latest` is mutable. Back up data and review upstream changes before upgrading.

## Installation and access

Sync this store, refresh local applications in 1Panel, and install the app. Set `PANEL_APP_PORT_HTTP` and `APP_BIND_IP` as needed.

The template preserves upstream's local-only default, `127.0.0.1:8080`. Use the server locally or an access-controlled 1Panel reverse proxy. Adjust `APP_BIND_IP` only when trusted LAN access is required.

Set `CORS_ORIGIN` to the actual browser origin, including scheme and port, without a path; the default is `http://localhost:8080`. Update it when changing the port or domain. There is no login authentication; CORS cannot replace access control, and write APIs should not be publicly exposed.

## Persistence and backup

The `toolnest-data` named volume maps to `/app/data`, storing favorites, preferences and reports. A named volume preserves the data-directory permissions required by the non-root image user. The actual volume name has a Compose project prefix; check `docker volume ls`.

Stop the app before backing up the volume. Avoid data-volume deletion during uninstall and do not use `docker compose down -v` as a routine stop command.

## Browser requirements

HTTPS is recommended. Some browser tools require a secure context and may not work fully over plain LAN HTTP. This template does not inject the fnOS package's HTTP compatibility layer.

## Verification scope

Upstream deployment files, published image architectures, package structure, forms and Compose variables have been checked. Actual 1Panel installation, image pulls and runtime behavior still require verification on the target server.

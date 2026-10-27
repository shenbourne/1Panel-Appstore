# Nav-Site for 1Panel

Self-hosted navigation and bookmarks, with an administration interface and file uploads.

## Image and requirements

- Upstream: <https://github.com/shenbourne/Nav-Site>
- Image: `shenbourne/nav-site:latest` on Docker Hub.
- Published architectures: amd64, checked against the current Docker Hub `latest` manifest; attestation-only `unknown/unknown` entries are excluded.
- Container port: `3000`; default host port: `3000`.
- Requires the external Docker network `1panel-network`.

`latest` is mutable. Back up data and review upstream changes before upgrading.

## Installation and access

Sync this store, refresh local applications in 1Panel, and install the app. Set `PANEL_APP_PORT_HTTP` and `APP_BIND_IP` as needed.

The default bind address is `0.0.0.0`. Visit `http://SERVER:3000`, adjusting the port if changed. The initial administrator is `admin`; supply `NAV_ADMIN_PASSWORD` with at least 12 characters. It is used only when creating the initial account and will not reset an existing password.

Leave `TRUST_PROXY` empty for direct access. Set it to `1` behind one trusted reverse proxy. The service generates and persists its JWT secret; this template does not ship a fixed secret.

## Persistence and backup

`./data` maps to `/app/data` and stores navigation content, authentication configuration and uploads. Stop the app and back up the entire installed `data` directory. Preserve file permissions and do not share the directory across instances.

## Verification scope

Upstream deployment files, published image architectures, package structure, forms and Compose variables have been checked. Actual 1Panel installation, image pulls and runtime behavior still require verification on the target server.

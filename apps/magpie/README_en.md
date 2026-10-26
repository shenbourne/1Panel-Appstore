# Magpie for 1Panel Local Apps

This local app runs the official Magpie Docker image, `ghcr.io/yetone/magpie:latest`, in container gateway mode. Official documentation: <https://usemagpie.ai/docs/docker>.

## Requirements

- 1Panel and Docker are installed.
- The external Docker network `1panel-network` already exists. If needed, create it with `docker network create 1panel-network`.
- The host binding defaults to `0.0.0.0`. You can restrict it to a specific interface during installation; use a firewall as well.

## Installation Fields

| Field | Default | Description |
| --- | --- | --- |
| `PANEL_APP_PORT_HTTP` | `3430` | Host port for the Web UI; the container port is `3430` |
| `PANEL_APP_PORT_GATEWAY` | `3425` | Host port for the API gateway; the container port is `3425` |
| `MAGPIE_WEB_KEY` | Empty (required) | Web access key; at least 16 characters using only letters, digits, and `-`, `.`, `_`, `~` |
| `MAGPIE_BIND_IP` | `0.0.0.0` | Host bind IPv4 address; `127.0.0.1` allows host access only |
| `MAGPIE_PUBLIC_URL` | Empty (optional) | Full public URL when using a domain or reverse proxy, for example `https://magpie.example.com` |

`MAGPIE_WEB_KEY` is displayed as a password field and is intentionally blank by default. It must be set during installation. To generate a compatible random key:

```bash
openssl rand -hex 24
```

The container command is `web --addr 0.0.0.0:3430 --no-open`. Configuration is stored in the Docker named volume `magpie-config` and mounted at `/config`. The named volume is used to handle permissions correctly for container UID `65532`. Do not replace it with a root-owned host directory that UID `65532` cannot write to.

## Import and Install

1. Copy the complete `magpie` directory into 1Panel's local app directory. A common location is `/opt/1panel/resource/apps/local`.
2. Refresh the local app list in 1Panel.
3. Open Magpie, set the ports and `MAGPIE_WEB_KEY`, optionally set `MAGPIE_PUBLIC_URL`, then install.

The actual installation root can vary by 1Panel version or deployment. Use the path configured by your panel.

## Open the Web UI

After installation, open:

```text
http://<server-address>:3430/?k=<MAGPIE_WEB_KEY>
```

When using an HTTPS reverse proxy, open the public domain and include the same `?k=` parameter.

## API Gateway

Create a gateway key in the Web UI before making API requests. The default base URL is:

```text
http://<server-address>:3425/v1
```

The Web access key and gateway keys serve different purposes; do not use one in place of the other. The UI port `3430` also supports `/v1` routes. If you configure an HTTPS reverse proxy for the UI, you can use `https://<domain>/v1` consistently and avoid exposing `3425` separately.

## Backup and Uninstall

The `magpie-config` volume stores configuration, subscription sign-ins and plugins. Stop the app and back up the volume before upgrading or uninstalling, for example by archiving it through a temporary container. The actual Docker volume name includes a Compose project prefix; check `docker volume ls`.

Whether 1Panel removes the data volume during uninstall depends on the panel version and the selected uninstall options. Preservation is not guaranteed. Do not uninstall or delete the volume without a backup.

## Subscriptions and OAuth

When adding a subscription through OAuth, complete the provider's sign-in in your browser. The redirect to localhost may fail to load because localhost points to your own computer. Copy the complete URL from the browser address bar, including its query parameters, and paste it into the Callback URL field in Magpie's sign-in dialog.

## Container Mode Limitations

Container gateway mode does not provide the desktop/local Agents, Sessions, or Library features. Use the appropriate local runtime when those capabilities are required.

## HTTPS and Security

Expose the Web UI through an HTTPS reverse proxy when possible. The proxy target can be `http://127.0.0.1:3430`; this entry point also supports `/v1` routes. Do not expose an unencrypted HTTP management interface or API directly to the internet, and protect both `MAGPIE_WEB_KEY` and all gateway keys.

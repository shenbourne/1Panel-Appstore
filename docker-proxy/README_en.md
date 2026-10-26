## Introduction

**Docker Proxy** is a self-hosted Docker image acceleration and management service that routes pulls for Docker Hub, GHCR, Quay, K8s, MCR, Elastic and NVCR by request Host with streaming forwarding, and ships the HubCMD-UI management panel.

## Features

- **Zero Disk Cache**: A single process routes by Host to the major public registries, performs server-side token authentication and forwards the stream without writing to disk or consuming local storage.
- **Multi-Registry Acceleration**: Accelerates and centrally manages Docker Hub, GHCR, Quay, K8s Registry, MCR, Elastic, NVCR and other popular registries.
- **Upstream Account Authentication**: Configure upstream registry credentials so the proxy exchanges them for a bearer token, enabling private Docker Hub pulls and easing official rate limits.
- **HubCMD-UI Management Panel**: Add, edit and remove proxies in the browser, tune server parameters with hot reload, and use image search, docs, container management and monitoring alerts.
- **Dashboard and Traffic Monitoring**: Real-time views of server resources, container status and network traffic, plus client-side image pull metrics and threshold alerts.
- **IP Access Control**: IP allowlists and denylists let you control which single IPs or CIDR ranges may pull images through the service.

# Vernissage Proxy

[![Nginx](https://img.shields.io/badge/Nginx-Latest-009639.svg?style=flat)](https://www.nginx.com)
[![Platforms macOS | Linux | Windows](https://img.shields.io/badge/Platforms-macOS%20%7C%20Linux%20%7C%20Windows-lightgray.svg?style=flat)](https://www.nginx.com)

Small Nginx-based reverse proxy for the **Vernissage** platform. It exposes one public host and routes each request either to the **Vernissage Server** API or the **Vernissage Web** client.

The proxy is intentionally simple: routing is based on request path and headers so browser traffic reaches the web app, while API, federation, and machine-readable requests reach the backend.

## Quick Links

- Project website: [joinvernissage.org](https://joinvernissage.org)
- Documentation: [docs.joinvernissage.org](https://docs.joinvernissage.org)
- API server: [VernissageServer](https://github.com/VernissageApp/VernissageServer)
- Web client: [VernissageWeb](https://github.com/VernissageApp/VernissageWeb)
- iOS client: [VernissageMobile](https://github.com/VernissageApp/VernissageMobile)

## Highlights

- Single-entry reverse proxy for the Vernissage stack
- Header-based routing for API and machine-readable requests
- Path-based routing for API and federated endpoints
- Edge rejection of common scanner paths before they reach the API or web app
- Docker-friendly deployment with a minimal Nginx image
- Current configuration tailored for Fly.io private networking

## How Routing Works

The routing logic lives in [`nginx.conf`](nginx.conf).

| Request match | Target | Notes |
| --- | --- | --- |
| `/api/v1/*` | backend | Main Vernissage API |
| `/.well-known/*` | backend | Federated discovery endpoints such as WebFinger |
| `/rss/*` | backend | Feed endpoints |
| `/atom/*` | backend | Feed endpoints |
| `Accept` or `Content-Type` contains `json` | backend | Case-insensitive match, applies outside the explicit API paths too |
| everything else | frontend | Regular browser traffic goes to Vernissage Web |

Before routing, the proxy returns `404 Not Found` for paths that target technologies Vernissage does not use. This includes PHP and WordPress probes, sensitive dotfiles such as `.env` and `.git`, dependency manifests, container configuration files, and administration or diagnostics endpoints from unrelated stacks. These requests are handled entirely by Nginx and never start Angular SSR or reach the API.

Federation endpoints under `/.well-known/*` are not part of this filter and continue to be routed to the backend.

In practice:

- `GET /api/v1/timelines/home` always goes to the API
- `GET /.well-known/webfinger` always goes to the API
- `GET /` with `Accept: application/json` goes to the API
- `GET /` from a normal browser request goes to the web client

## Runtime Topology

The committed configuration expects two internal upstream services:

- `vernissage-api.internal:8080` as `backend`
- `vernissage-web.internal:8080` as `frontend`

For every proxied request, Nginx forwards request headers and preserves:

- `Host`
- `X-Forwarded-Host`

This setup is designed for deployments where the API and web app are already running behind private service discovery and the proxy becomes the single public entrypoint.

## Repository Layout

- `nginx.conf` - reverse proxy rules and upstream selection
- `Dockerfile` - minimal Nginx container image
- `fly.toml` - Fly.io app configuration

## Local Development

This repository does not contain the API or web application itself. To test the proxy locally, run the related projects first:

- API: usually on `http://localhost:8080`
- Web: usually on `http://localhost:4200`

Then adapt `nginx.conf` for local upstream addresses, for example:

- change `vernissage-api.internal:8080` to `host.docker.internal:8080` or another reachable API host
- change `vernissage-web.internal:8080` to `host.docker.internal:4200` or another reachable web host

Build and run the proxy image:

```bash
docker build -t vernissage-proxy .
docker run --rm -p 8081:8080 vernissage-proxy
```

Then open `http://localhost:8081`.

## Deployment Notes

The recommended production form is a Docker image built from this repository.

The current Nginx config is Fly.io-oriented:

- it resolves private `.internal` services,
- it uses the Fly resolver at `[fdaa::3]`,
- `fly.toml` contains the runtime settings for deployment.

If you deploy outside Fly.io, update the upstream hostnames and, if needed, the resolver configuration.

## Contributing

Contributions are welcome.

1. Keep routing changes small and explicit.
2. Validate that API requests, browser requests, and federation endpoints still reach the correct upstream.
3. Document any new routing rules in this README.

## License

This project is licensed under the [Apache License 2.0](LICENSE).

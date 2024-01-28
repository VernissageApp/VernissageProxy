# Vernissage Proxy

[![Nginx](https://img.shields.io/badge/Nginx-Latest-blue.svg?style=flat)](https://www.nginx.com)
[![Platforms macOS | Linux | Windows](https://img.shields.io/badge/Platforms-macOS%20%7C%20Linux%20%7C%20Windows%20-lightgray.svg?style=flat)](https://www.nginx.com)

Application which is Proxy component for Vernissage photos sharing platform.
The proxy is used to redirect traffic from to the relevant applications running behind the proxy based on the web request headers.
Requests that have `Accept=application/json` (and smimilar) set are redirected directly to the Vernissage API (Swift), all others to the Vernissage Web (Angular).

## Architecture

```
                                          +-----------------------------+
              +-------------------------->|   VernissageWeb (Angular)   |
              |                           +-------------+---------------+
              |                                         |
+-------------+---------------+                         |
|   VernissageProxy (Nginx)   |                         |
+-------------+---------------+                         |
              |                                         |
              |                           +-------------+---------------+
              +-------------------------->|   VernissageAPI (Swift)     |
              application/json            +-----------------------------+
```

## Docker

In production environments, it is best to use a [docker image](https://hub.docker.com/repository/docker/mczachurski/vernissage-web).
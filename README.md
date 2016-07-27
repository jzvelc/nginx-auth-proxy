# Nginx Auth Proxy
This image provides a basic HTTP authentication for services.

## Example
```yml
version: "2"

services:
  proxy:
    build: .
    image: nginx-auth-proxy:latest
    environment:
      - PROXY_USERNAME=admin
      - PROXY_PASSWORD=admin
      - PROXY_PASSTHROUGH=192.168.1.0/24;192.168.2.0/24
      - PROXY_ADDRESS=api
      - PROXY_PORT=8080
    ports:
      - "8090:80"
    restart: always

  api:
    image: fkautz/example-go-rest-api
    ports:
      - "8080:8080"
    restart: always
```

## Environment variables
### PROXY_USERNAME
Defaults to `admin`.
### PROXY_PASSWORD
Defaults to `admin`.
### PROXY_HOST
Host name which proxy will react to (used as a `server_name` directive in nginx conf). Defaults to `_`.
### PROXY_PASSTHROUGH
Optionally specify CIDR addresses which will bypass authentication.
### PROXY_ADDRESS
### PROXY_PORT

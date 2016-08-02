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
      - PROXY_TRUST=192.168.1.0/24
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
### PROXY_TRUST
Optionally specify CIDR addresses for `set_real_ip_from` entries.
### PROXY_ADDRESS
Proxy service address.
### PROXY_PORT
Proxy service port.
### SERVER_BLOCK_USER_DATA
Additional config passed to server block.
### LOCATION_BLOCK_USER_DATA
Additional config passed to location block.

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
      - SERVICE_ADDRESS=api
      - SERVICE_PORT=8080
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
### PROXY_PASSWORD
### PROXY_HOST
Host name which proxy will react to (used as a `server_name` directive in nginx conf). Defaults to `_`.
### PROXY_PASSTHROUGH
Specify CIDR addresses which won't require auth.
### SERVICE_ADDRESS
### SERVICE_PORT

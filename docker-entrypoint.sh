#!/bin/bash

NGINX_TEMPLATE_FILE=/etc/nginx/conf.d/default.template
NGINX_PASSWORD_FILE=/etc/nginx/service.pwd

# Build the password file
htpasswd -b -c ${NGINX_PASSWORD_FILE} ${PROXY_USERNAME} ${PROXY_PASSWORD} &>/dev/null

if [[ -n "${PROXY_PASSTHROUGH}" ]]; then
  PROXY_PASSTHROUGH=${PROXY_PASSTHROUGH//;/$'\n'}
  for cidr in ${PROXY_PASSTHROUGH}; do
    rules+="allow ${cidr}; "
  done
  rules="satisfy any; ${rules}deny all;"
fi

# Build nginx virtual host file for the service to protect
cat > ${NGINX_TEMPLATE_FILE} <<EOL
include /etc/nginx/proxy.conf;
server {
    listen 80 default_server;
    server_name ${PROXY_HOST};

    ${rules}

    auth_basic "Protected Service";
    auth_basic_user_file ${NGINX_PASSWORD_FILE};

    location / {
        proxy_pass http://${SERVICE_ADDRESS}:${SERVICE_PORT};
    }
}
EOL

envsubst < ${NGINX_TEMPLATE_FILE} > /etc/nginx/conf.d/default.conf && nginx -g "daemon off;"

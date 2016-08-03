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

if [[ -n "${PROXY_TRUST}" ]]; then
  PROXY_TRUST=${PROXY_TRUST//;/$'\n'}
  for cidr in ${PROXY_TRUST}; do
    real_ip_from+="set_real_ip_from ${cidr}; "
  done
fi

# Append user data
if [[ -n "${SERVER_BLOCK_USER_DATA}" ]]; then
  echo -e "${SERVER_BLOCK_USER_DATA}" >> /etc/nginx/server.conf
fi
if [[ -n "${LOCATION_BLOCK_USER_DATA}" ]]; then
  echo -e "${LOCATION_BLOCK_USER_DATA}" >> /etc/nginx/proxy.conf
fi

# Build nginx virtual host file for the service to protect
cat > ${NGINX_TEMPLATE_FILE} <<EOL
include /etc/nginx/helpers.conf;
server {
    listen 80 default_server;
    server_name ${PROXY_HOST};

    ${rules}

    auth_basic "Protected Service";
    auth_basic_user_file ${NGINX_PASSWORD_FILE};

    ${real_ip_from}

    include /etc/nginx/server.conf;

    location / {
        proxy_pass http://${PROXY_ADDRESS}:${PROXY_PORT};

        include /etc/nginx/proxy.conf;
    }
}
EOL

envsubst < ${NGINX_TEMPLATE_FILE} > /etc/nginx/conf.d/default.conf

nginx -g "daemon off;"

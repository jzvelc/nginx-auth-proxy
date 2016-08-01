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

if [[ "${PROXY_PROTOCOL}" == "1" ]]; then
  PROXY_PROTOCOL=" proxy_protocol"
  default_conf="proxy_set_header X-Real-IP \$proxy_protocol_addr;\nproxy_set_header X-Forwarded-Proto tcp;"
else
  PROXY_PROTOCOL=""
  default_conf="proxy_set_header X-Real-IP \$remote_addr;\nproxy_set_header X-Forwarded-Proto \$proxy_x_forwarded_proto;"
fi

echo -e "${default_conf}" | cat - /etc/nginx/proxy.conf > /etc/nginx/proxy.conf.tmp
mv /etc/nginx/proxy.conf.tmp /etc/nginx/proxy.conf

# Build nginx virtual host file for the service to protect
cat > ${NGINX_TEMPLATE_FILE} <<EOL
include /etc/nginx/helpers.conf;
server {
    listen 80 default_server${PROXY_PROTOCOL};
    server_name ${PROXY_HOST};

    ${rules}

    auth_basic "Protected Service";
    auth_basic_user_file ${NGINX_PASSWORD_FILE};

    location / {
        proxy_pass http://${PROXY_ADDRESS}:${PROXY_PORT};

        include /etc/nginx/proxy.conf;
    }
}
EOL

envsubst < ${NGINX_TEMPLATE_FILE} > /etc/nginx/conf.d/default.conf && nginx -g "daemon off;"

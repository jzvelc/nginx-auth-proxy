FROM nginx:stable

RUN apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -y \
  apache2-utils \
  && rm -rf /var/lib/apt/lists/*

COPY helpers.conf /etc/nginx/helpers.conf
COPY proxy.conf /etc/nginx/proxy.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

ENV PROXY_USERNAME="admin"
ENV PROXY_PASSWORD="admin"
ENV PROXY_PASSTHROUGH=""
ENV PROXY_HOST="_"
ENV PROXY_PROTOCOL="0"

EXPOSE 80

CMD ["/docker-entrypoint.sh"]

FROM centos:7.6.1810

ARG ARG_NGINX_VERSION=1.15.9
ARG ARG_NGINX_ARTIFACT=https://nexus.fanthreesixty.com/repository/infrastructure-archives/nginx-${ARG_NGINX_VERSION}.tar.gz
ARG ARG_NGINX_PROXY_CONNECT_VERSION=0.1

ENV NGINX_VERSION=${ARG_NGINX_VERSION}
ENV NGINX_ARTIFACT=${ARG_NGINX_ARTIFACT}
ENV NGINX_PATH=/opt/nginx-${NGINX_VERSION}
ENV NGINX_PROXY_CONNECT_VERSION=${ARG_NGINX_PROXY_CONNECT_VERSION}

COPY docker-entrypoint.sh /opt/bin/docker-entrypoint.sh

RUN yum install -y gcc pcre pcre-devel openssl openssl-devel zlib-devel \
    && groupadd -g 9999 jenkins \
    && adduser -M -g 9999 -u 9999 jenkins \
    && chown -R jenkins:jenkins /opt

RUN mkdir -p /opt/bin && cd /opt \
    && curl -sS ${NGINX_ARTIFACT} | tar xvz \
    && curl -sS ${NGINX_PROXY_CONNECT_ARTIFACT} | tar xvz

RUN chmod +x /opt/bin/docker-entrypoint.sh

WORKDIR ${NGINX_PATH}

CMD ["/opt/bin/docker-entrypoint.sh"]

FROM rockylinux:8.9 AS downloader

SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION

WORKDIR /app
RUN curl -SL https://github.com/i2b2/i2b2-webclient/archive/refs/tags/v${APP_VERSION}.tar.gz \
  | tar -xzC . \
&& mv i2b2-webclient-${APP_VERSION} webclient


FROM rockylinux:8.9 as i2b2-web

SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION

RUN yum -y install httpd mod_ssl php && \
    yum clean all

WORKDIR /var/www/html
COPY --from=downloader /app/webclient .

COPY *.sh /
COPY *.conf /conftemp/etc/httpd/conf.d/

ENV APP_ID=i2b2-wildfly

CMD ["/run-httpd.sh"]

FROM rockylinux:8.9 AS downloader

ARG I2B2_VERSION=1.8.1.0001

WORKDIR /app
RUN curl -SL https://github.com/i2b2/i2b2-webclient/archive/refs/tags/v${I2B2_VERSION}.tar.gz \
  | tar -xzC . \
&& mv i2b2-webclient-${I2B2_VERSION} webclient


FROM rockylinux:8.9 as i2b2-web

SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

RUN yum -y install httpd mod_ssl php && \
    yum clean all

WORKDIR /var/www/html
COPY --from=downloader /app/webclient .

COPY *.sh /
COPY *.conf /conftemp/etc/httpd/conf.d/

ENV APP_ID=i2b2-wildfly

CMD ["/run-httpd.sh"]

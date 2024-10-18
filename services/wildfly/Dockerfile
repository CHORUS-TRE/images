# I2B2 old image
FROM i2b2/i2b2-wildfly:v1.8.0.0001 AS i2b2

# Default image
FROM docker.io/bitnami/wildfly:26.1.1-debian-11-r32

USER root
COPY --from=i2b2 /opt/jboss/wildfly/customization /opt/bitnami/wildfly/customization
RUN chown root:root -R /opt/bitnami/wildfly/customization
RUN chmod +x /opt/bitnami/wildfly/customization/execute.sh
RUN sed -i 's/\/opt\/jboss\/wildfly/\/opt\/bitnami\/wildfly/g' /opt/bitnami/wildfly/customization/execute.sh

#I2B2 env
ENV DS_IM_PASS=
ENV DS_TYPE=postgres
ENV DS_HIVE_USER=i2b2hive
ENV DS_HIVE_PASS=demouser
ENV DS_IM_PORT=
ENV DS_WD_USER=i2b2workdata
ENV DS_CRC_IP=i2b2-pg
ENV DS_HIVE_DB=i2b2hive
ENV DS_CRC_USER=i2b2demodata
ENV DS_CRC_PASS=demouser
ENV DS_ONT_PORT=5432
ENV DS_ONT_DB=i2b2metadata
ENV DS_ONT_IP=i2b2-pg
ENV DS_DUMMY=
ENV DS_PORT=5432
ENV DS_IM_IP=
ENV DS_IP=i2b2-pg
ENV DS_PM_PASS=demouser
ENV DS_IM_USER=i2b2imdata
ENV DS_WD_PORT=
ENV DS_WD_IP=
ENV DS_IM_DB=i2b2imdata
ENV DS_ONT_PASS=demouser
ENV DS_WD_DB=i2b2workdata
ENV DS_ONT_USER=i2b2metadata
ENV DS_PM_USER=i2b2pm
ENV DS_PM_DB=i2b2pm
ENV DS_CRC_DB=i2b2demodata
ENV DS_WD_PASS=demouser
ENV DS_PM_PORT=
ENV DS_PM_IP=
ENV DS_CRC_PORT=5432

ENTRYPOINT [ "/opt/bitnami/scripts/wildfly/entrypoint.sh" ]

# Start wildfly
CMD [ "/opt/bitnami/wildfly/customization/execute.sh" ]

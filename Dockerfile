FROM openjdk:8-alpine
USER root
# Configuration variables.
ENV JIRA_HOME     /var/atlassian/jira
ENV JIRA_INSTALL  /opt/atlassian/jira
ENV JIRA_VERSION  8.11.0

# Install Atlassian JIRA and helper tools and setup initial home
# directory structure.
RUN set -x \
    && apk add --no-cache curl xmlstarlet bash ttf-dejavu libc6-compat \
    && mkdir -p                "${JIRA_HOME}" \
    && mkdir -p                "${JIRA_HOME}/caches/indexes" \
    && chmod -R 700            "${JIRA_HOME}" \
    && chown -R root:root  "${JIRA_HOME}" \
    && mkdir -p                "${JIRA_INSTALL}/conf/Catalina" \
    && curl -Ls                "https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-core-${JIRA_VERSION}.tar.gz" | tar -xz --directory "${JIRA_INSTALL}" --strip-components=1 --no-same-owner \
    && curl -Ls                "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.45.tar.gz" | tar -xz --directory "${JIRA_INSTALL}/lib" --strip-components=1 --no-same-owner "mysql-connector-java-5.1.45/mysql-connector-java-5.1.45-bin.jar" \
    && rm -f                   "${JIRA_INSTALL}/lib/postgresql-9.1-903.jdbc4-atlassian-hosted.jar" \
    && curl -Ls                "https://jdbc.postgresql.org/download/postgresql-42.2.1.jar" -o "${JIRA_INSTALL}/lib/postgresql-42.2.1.jar" \
    && chmod -R 700            "${JIRA_INSTALL}/conf" \
    && chmod -R 700            "${JIRA_INSTALL}/logs" \
    && chmod -R 700            "${JIRA_INSTALL}/temp" \
    && chmod -R 700            "${JIRA_INSTALL}/work" \
    && chown -R root:root  "${JIRA_INSTALL}/conf" \
    && chown -R root:root  "${JIRA_INSTALL}/logs" \
    && chown -R root:root  "${JIRA_INSTALL}/temp" \
    && chown -R root:root  "${JIRA_INSTALL}/work" \
    && sed --in-place          "s/java version/openjdk version/g" "${JIRA_INSTALL}/bin/check-java.sh" \
    && echo -e                 "\njira.home=$JIRA_HOME" >> "${JIRA_INSTALL}/atlassian-jira/WEB-INF/classes/jira-application.properties" \
    && touch -d "@0"           "${JIRA_INSTALL}/conf/server.xml" \
    && chown -R root:root  "/opt/atlassian/jira/bin/start-jira.sh" \
    && chmod 777               "/opt/atlassian/jira/bin/start-jira.sh" \
    && chown -R root:root  "/opt/atlassian/"

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'root' but
# here we only ever run one process anyway.
USER root:root
RUN chown -R root:root /opt
RUN chmod 777 /
RUN chmod 777 /opt/atlassian/jira/bin/start-jira.sh

# Expose default HTTP connector port.
EXPOSE 80

# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted as well as parts of the installation
# directory due to eg. logs.
VOLUME ["/var/atlassian/jira", "/opt/atlassian/jira/logs"]
USER root
# Set the default working directory as the installation directory.
WORKDIR /var/atlassian/jira
RUN ["chmod", "+x", "/opt/atlassian/jira/bin/start-jira.sh"]
COPY "docker-entrypoint.sh" "/"
USER root
# ENTRYPOINT ["/docker-entrypoint.sh"]
# Run Atlassian JIRA as a foreground process by default.
CMD ["/opt/atlassian/jira/bin/start-jira.sh", "-fg"]

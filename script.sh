#!/bin/bash
/usr/lib/postgresql/9.3/bin/postgres -D /var/lib/postgresql/9.3/main -c config_file=/etc/postgresql/9.3/main/postgresql.conf
/opt/atlassian/jira/bin/start-jira.sh -fg

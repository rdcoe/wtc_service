FUNCTIONS=$WC_ROOT/functions.bash
LOG=$WC_ROOT/wcappctl.log
IS_STARTED=is_started

JAVA_HOME=$WC_ROOT/Java
DS_HOME=$WC_ROOT/WindchillDS
WC_HOME=$WC_ROOT/Windchill
APACHE_HOME=$WC_ROOT/Apache

START_DS=$DS_HOME/server/bin/start-ds
STOP_DS=$DS_HOME/server/bin/stop-ds
DS_PID=$DS_HOME/server/logs/server.pid
DS_PROC=${JAVA_HOME}/bin/java
DS_PROC_VERIFY="DirectoryServer"

WINDCHILL=$WC_HOME/bin/windchill
WINDCHILL_PID=/var/run/windchill.pid
WINDCHILL_PROC=$JAVA_HOME/jre/bin/java
WINDCHILL_PROC_VERIFY="-server"

APACHE_CTL=$APACHE_HOME/bin/apachectl
APACHE_CONF=$APACHE_HOME/conf
HTTPD_PID=$APACHE_HOME/logs/httpd.pid
HTTPD_PROC=$APACHE_HOME/bin/httpd

SQL_SERVER=$DB_HOST
SQL_SERVER_PORT=$DB_PORT

#!/bin/sh -e

# MySQL Connector/J version
MYSQL_CJ_VERSION="8.0.23"

# Download MySQL Connector/J
mkdir -p "$SAG_HOME/MWS/lib"
curl -sSLf --retry 5 "https://repo1.maven.org/maven2/mysql/mysql-connector-java/${MYSQL_CJ_VERSION}/mysql-connector-java-${MYSQL_CJ_VERSION}.jar" -o "$SAG_HOME/MWS/lib/mysql-connector-java.jar"

# Create OSGi bundle for MWS
cat - > "$SAG_HOME/MWS/lib/mysql-connector-java.bnd" <<EOF
# attach as fragment to the caf.server bundle
Fragment-Host: com.webmethods.caf.server
Bundle-SymbolicName: mysql-connector-java-
Bundle-Version: ${MYSQL_CJ_VERSION}
Include-Resource: mysql-connector-java.jar
-exportcontents: *
Bundle-ClassPath: mysql-connector-java.jar
Import-Package: *;resolution:=optional
EOF

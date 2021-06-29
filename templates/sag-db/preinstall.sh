#!/bin/sh -e

# MySQL Connector/J version
MYSQL_CJ_VERSION="8.0.23"

# Download MySQL Connector/J
mkdir -p "$SAG_HOME/common/lib/ext"
curl -sSLf --retry 5 "https://repo1.maven.org/maven2/mysql/mysql-connector-java/${MYSQL_CJ_VERSION}/mysql-connector-java-${MYSQL_CJ_VERSION}.jar" -o "$SAG_HOME/common/lib/ext/mysql-connector-java.jar"

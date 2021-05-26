#!/bin/sh -e

# if managed image
if [ -d $SAG_HOME/profiles/SPM ] ; then
    # point to local SPM
    export CC_SERVER=http://localhost:8092/spm
    export CC_WAIT=180
    export __is_instance_name=${__is_instance_name:-default}
    
    echo "Verifying managed container $CC_SERVER ..."
    sagcc get inventory products -e integrationServer --wait-for-cc

    echo "Start the instance ..."
    sagcc exec lifecycle components "OSGI-IS_${__is_instance_name}" start -e DONE --sync-job

    echo "Verifying status ..."
    sagcc get monitoring runtimestatus "OSGI-IS_${__is_instance_name}" -e ONLINE
    sagcc get monitoring runtimestatus "integrationServer-${__is_instance_name}" -e ONLINE
fi

function downloadFileFromURL() {
    local urlPath="$1"
    local destination="$2"
    local filename="$(basename $urlPath)"
    if [ -e "$destination/$filename" ]; then
        echo "- Already downloaded $filename, skipping"
        return 0
    elif curl -sSLf --retry 5 "$urlPath" -o "$destination/$filename"; then
        echo "- Successfully downloaded $filename"
        return 0
    else
        echo "! Error while downloading $urlPath"
        return 1
    fi
}

function downloadFromMavenCentral() {
    local urlPath="$1"
    local destination="$2"
    downloadFileFromURL "https://repo1.maven.org/maven2/$urlPath" "$destination"
}

function invokeWmService() {
    local servicePath="$1"
    local pwd=${__is_administrator_password:-manage}
    echo "- Calling $servicePath ..."
    curl -sSLf -u "Administrator:$pwd" "http://localhost:5554/invoke/$servicePath" >/dev/null || return 1
}

IS_HOME="$SAG_HOME/IntegrationServer"
IS_INSTANCE="$IS_HOME/instances/${__is_instance_name}"

echo "Installing JDBC JARs ..."
IS_CUSTOM_JARS="$IS_HOME/lib/jars/custom"
mkdir -p "$IS_CUSTOM_JARS"
downloadFromMavenCentral "com/ingres/jdbc/iijdbc/10.2-4.1.10/iijdbc-10.2-4.1.10.jar" "$IS_CUSTOM_JARS"
downloadFromMavenCentral "com/microsoft/sqlserver/mssql-jdbc/9.2.1.jre15/mssql-jdbc-9.2.1.jre15.jar" "$IS_CUSTOM_JARS"
downloadFromMavenCentral "com/oracle/ojdbc/ojdbc8/19.3.0.0/ojdbc8-19.3.0.0.jar" "$IS_CUSTOM_JARS"
downloadFromMavenCentral "mysql/mysql-connector-java/8.0.23/mysql-connector-java-8.0.23.jar" "$IS_CUSTOM_JARS"
downloadFromMavenCentral "org/postgresql/postgresql/42.2.19/postgresql-42.2.19.jar" "$IS_CUSTOM_JARS"

echo "Installing WmDeployerResource ..."
rm -Rf "$IS_INSTANCE/packages/WmDeployerResource"
mkdir -p "$IS_INSTANCE/packages/WmDeployerResource"
pushd "$IS_INSTANCE/packages/WmDeployerResource"
$SAG_HOME/jvm/jvm/bin/jar -xf "$IS_INSTANCE/packages/WmDeployer/pub/WmDeployerResource.zip"
popd

echo "Configuring Remote Server alias ..."
sed -i "s#$(hostname)#localhost#g" "$IS_INSTANCE/config/remote.cnf"

echo "Configuring master password expiration ..."
invokeWmService "wm.server.internalOutboundPasswords/setMasterExpireInterval?expireInterval=0"

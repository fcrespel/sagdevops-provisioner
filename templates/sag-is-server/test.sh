#!/bin/sh -e

# if managed image
if [ -d $SAG_HOME/profiles/SPM ] ; then
    # point to local SPM
    export CC_SERVER=http://localhost:8092/spm
    export CC_WAIT=180
    export __is_instance_name=${__is_instance_name:-default}

    echo "Verifying managed container $CC_SERVER ..."
    sagcc get inventory products -e integrationServer --wait-for-cc

    echo "Verifying fixes ..."
    sagcc get inventory fixes -e wMFix.integrationServer.Core

    echo "Verifying instances ..."
    sagcc get inventory components -e "OSGI-IS_${__is_instance_name}"

    echo "Start the instance ..."
    sagcc exec lifecycle components "OSGI-IS_${__is_instance_name}" start -e DONE --sync-job

    echo "Verifying status ..."
    sagcc get monitoring runtimestatus "OSGI-IS_${__is_instance_name}" -e ONLINE
    sagcc get monitoring runtimestatus "integrationServer-${__is_instance_name}" -e ONLINE
fi

echo "Verifying product runtime ..."
curl -sf http://`hostname`:5555/invoke/wm.server/ping

if [ -d $SAG_HOME/profiles/SPM ] ; then
    echo "Shut down the instance ..."
    sagcc exec lifecycle components "OSGI-IS_${__is_instance_name}" stop -e DONE --sync-job
fi

echo "DONE testing"

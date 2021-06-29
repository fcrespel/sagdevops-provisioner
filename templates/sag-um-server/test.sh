#!/bin/sh -e

# if managed image
if [ -d $SAG_HOME/profiles/SPM ] ; then
    # point to local SPM
    export CC_SERVER=http://localhost:8092/spm
    export CC_WAIT=180
    export __um_instance_name=${__um_instance_name:-default}

    echo "Verifying managed container $CC_SERVER ..."
    sagcc get inventory products -e NUMRealmServer --wait-for-cc

    echo "Verifying fixes ..."
    sagcc get inventory fixes -e wMFix.NUMRealmServer

    echo "Verifying instances ..."
    sagcc get inventory components -e Universal-Messaging-${__um_instance_name}

    echo "Start the instance ..."
    sagcc exec lifecycle components Universal-Messaging-${__um_instance_name} start -e DONE --sync-job

    echo "Verifying status ..."
    sagcc get monitoring runtimestatus Universal-Messaging-${__um_instance_name} -e ONLINE
fi

if [ -d $SAG_HOME/profiles/SPM ] ; then
    echo "Shut down the instance ..."
    sagcc exec lifecycle components Universal-Messaging-${__um_instance_name} stop -e DONE --sync-job
fi

echo "DONE testing"

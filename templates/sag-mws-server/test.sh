#!/bin/sh -e

# if managed image
if [ -d $SAG_HOME/profiles/SPM ] ; then
    # point to local SPM
    export CC_SERVER=http://localhost:8092/spm
    export CC_WAIT=180
    export __mws_instance_name=${__mws_instance_name:-default}

    echo "Verifying managed container $CC_SERVER ..."
    sagcc get inventory products -e MwsProgramFiles --wait-for-cc
    
    echo "Verifying fixes ..."
    sagcc get inventory fixes -e wMFix.MwsProgramFiles

    echo "Verifying instances ..."
    sagcc get inventory components -e "OSGI-MWS_${__mws_instance_name}"

    echo "Start the instance ..."
    sagcc exec lifecycle components "OSGI-MWS_${__mws_instance_name}" start -e DONE --sync-job

    echo "Verifying status ..."
    sagcc get monitoring runtimestatus "OSGI-MWS_${__mws_instance_name}" -e ONLINE
fi

echo "Verifying product runtime ..."
RETRY=20
while [ $RETRY -gt 0 ] && ! curl -sf http://`hostname`:8585 -o /dev/null; do
    sleep 3
    RETRY=$((RETRY-1))
done
curl -sf http://`hostname`:8585 -o /dev/null

if [ -d $SAG_HOME/profiles/SPM ] ; then
    echo "Shut down the instance ..."
    sagcc exec lifecycle components "OSGI-MWS_${__mws_instance_name}" stop -e DONE --sync-job
fi

echo "DONE testing"
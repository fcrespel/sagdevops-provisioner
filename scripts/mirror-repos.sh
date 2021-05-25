#!/bin/sh

# Stop on error
set -e

# Start and initialize Command Central
NODES=local SAG_HOME=$CC_HOME $CC_HOME/provision.sh

# Add products mirror
sagcc add repository products mirror name=products-mirror sourceRepos=products artifacts=$MIRROR_PRODUCTS_ARTIFACTS platforms=LNXAMD64 --sync-job -c 10 -w $MIRROR_TIMEOUT -e DONE

# Add fixes mirror
sagcc add repository fixes mirror name=mirror sourceRepos=fixes productRepos=products-mirror artifacts=$MIRROR_FIXES_ARTIFACTS --sync-job -c 10 -w $MIRROR_TIMEOUT -e DONE

# Shutdown CCE/SPM
$CC_HOME/profiles/SPM/bin/shutdown.sh
$CC_HOME/profiles/CCE/bin/shutdown.sh

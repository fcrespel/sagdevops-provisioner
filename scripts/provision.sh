#!/bin/sh

# Stop on error
set -e

# Shutdown handler
function _shutdown() {
  [ ! -e "$SAG_HOME/profiles/SPM" ] || $SAG_HOME/profiles/SPM/bin/shutdown.sh
  $CC_HOME/profiles/SPM/bin/shutdown.sh
  $CC_HOME/profiles/CCE/bin/shutdown.sh
}
trap _shutdown SIGINT SIGTERM EXIT

# Script variables
TEMPLATE_NAME="${1:-sag-empty}"
TEMPLATE_DIR="$CC_HOME/profiles/CCE/data/templates/composite/$TEMPLATE_NAME"

# Provision, customize, test
[ ! -e "$TEMPLATE_DIR/preinstall.sh" ] || $TEMPLATE_DIR/preinstall.sh
$CC_HOME/provision.sh "$@"
[ ! -e "$TEMPLATE_DIR/postinstall.sh" ] || $TEMPLATE_DIR/postinstall.sh
[ ! -e "$TEMPLATE_DIR/test.sh" ] || $TEMPLATE_DIR/test.sh

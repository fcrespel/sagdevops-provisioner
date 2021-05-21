#!/bin/sh

# Stop on error
set -e

# Script variables
TEMPLATE_NAME="${1:-sag-empty}"
TEMPLATE_DIR="$CC_HOME/profiles/CCE/data/templates/composite/$TEMPLATE_NAME"

# Provision, customize, test
$CC_HOME/provision.sh "$@"
[ ! -e "$TEMPLATE_DIR/customize.sh" ] || $TEMPLATE_DIR/customize.sh
[ ! -e "$TEMPLATE_DIR/test.sh" ] || $TEMPLATE_DIR/test.sh

# Shutdown CCE/SPM
[ ! -e "$SAG_HOME/profiles/SPM" ] || $SAG_HOME/profiles/SPM/bin/shutdown.sh
$CC_HOME/profiles/SPM/bin/shutdown.sh
$CC_HOME/profiles/CCE/bin/shutdown.sh

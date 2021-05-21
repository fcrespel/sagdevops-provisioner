#!/bin/sh

# Download installer
if [ -n "$CC_INSTALLER" -a -n "$CC_INSTALLER_URL" ]; then
    if [ -e "$CC_INSTALLER.sh" ]; then
        echo "Installer $CC_INSTALLER already downloaded, skipping"
    else
        echo "Downloading installer from $CC_INSTALLER_URL/$CC_INSTALLER.sh ..."
        curl -kf "$CC_INSTALLER_URL/$CC_INSTALLER.sh" -o "$CC_INSTALLER.sh"
    fi
else
    echo "Installer URL and version not configured"
    exit 1
fi

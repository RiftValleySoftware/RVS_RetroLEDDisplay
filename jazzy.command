#!/bin/sh
CWD="$(pwd)"
MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
cd "${MY_SCRIPT_PATH}"

echo "Creating Docs for the RVS_RetroLEDDisplay Library\n"
rm -drf docs/*

jazzy  --readme ./README.md \
       --build-tool-arguments -scheme,"RVS_RetroLEDDisplay",-target,"RVS_RetroLEDDisplay" \
       --github_url https://github.com/RiftValleySoftware/RVS_RetroLEDDisplay \
       --title "RVS_RetroLEDDisplay Doumentation" \
       --min_acl public \
       --theme fullwidth
cp ./icon.png docs/
cp ./img/* docs/img

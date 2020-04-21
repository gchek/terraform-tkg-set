#!/usr/bin/env bash

VSPHERE_SERVER=$(cat ./outputs.json | jq -r '.vc_url.value')
SPHERE_USERNAME=$(cat ./outputs.json | jq -r '.cloud_username.value')
VSPHERE_PASSWORD=$(cat ./outputs.json | jq -r '.cloud_password.value')
VSPHERE_NETWORK=$(cat ./outputs.json | jq -r '.TKG_net_name.value')

if [ -f ./config.yaml ]; then
    rm ./config.yaml
fi


cat ./config.ini > ./config.yaml
echo "VSPHERE_NETWORK: $VSPHERE_NETWORK" >> ./config.yaml
echo "VSPHERE_SERVER: $VSPHERE_SERVER" >> ./config.yaml
echo "VSPHERE_USERNAME: $SPHERE_USERNAME"  >> ./config.yaml
echo "VSPHERE_PASSWORD: $VSPHERE_PASSWORD"  >> ./config.yaml
cp ./config.yaml ./.tkg/config.yaml


#!/usr/bin/env bash

export GOVC_URL=$(cat ./outputs.json | jq -r '.GOVC_vc_url.value')
export GOVC_USERNAME=$(cat ./outputs.json | jq -r '.cloud_username.value')
export GOVC_PASSWORD=$(cat ./outputs.json | jq -r '.cloud_password.value')
export GOVC_INSECURE=true

govc about
govc ls

TEMPLATES=$(govc folder.info /SDDC-Datacenter/vm/Templates | grep -c Name:)
if [ $TEMPLATES == 0  ]
then
  echo "Creating Templates Folder..."
  govc folder.create /SDDC-Datacenter/vm/Templates
fi

FOLDER=$(govc folder.info /SDDC-Datacenter/vm/TKG | grep -c Name:)
if [ $FOLDER == 0  ]
then
  echo "Creating TKG Folder..."
  govc folder.create /SDDC-Datacenter/vm/TKG
fi
POOL=$(govc pool.info /SDDC-Datacenter/host/Cluster-1/Resources/Compute-ResourcePool/TKG | grep -c Name:)
if [ $POOL == 0  ]
then
  echo "Creating TKG Pool..."
  govc pool.create /SDDC-Datacenter/host/Cluster-1/Resources/Compute-ResourcePool/TKG
fi
NETWORK=$(cat ./outputs.json  | jq -r '.TKG_net_name.value')
HAPROXY=$(cat ./outputs.json  | jq -r '.TKG_haproxy.value')
PHOTON=$(cat ./outputs.json  | jq -r '.TKG_photon.value')

PH=$(govc vm.info ${PHOTON} | grep -c Name:)
if [ $PH == 0 ]
then
  echo "Deploying" ${PHOTON}
  govc import.spec ${PHOTON}.ova | jq ".Name=\"$PHOTON\"" | jq ".NetworkMapping[0].Network=\"$NETWORK\"" > ${PHOTON}.json
  govc import.ova -dc="SDDC-Datacenter" -ds="WorkloadDatastore" -pool="Compute-ResourcePool" -folder="Templates" -options=${PHOTON}.json ${PHOTON}.ova
  govc snapshot.create -vm ${PHOTON} root
  govc vm.markastemplate ${PHOTON}
fi

HA=$(govc vm.info ${HAPROXY} | grep -c Name:)
if [ $HA == 0 ]
then
  echo "Deploying" ${HAPROXY}
  govc import.spec ${HAPROXY}.ova | jq ".Name=\"$HAPROXY\"" | jq ".NetworkMapping[0].Network=\"$NETWORK\"" > ${HAPROXY}.json
  govc import.ova -dc="SDDC-Datacenter" -ds="WorkloadDatastore" -pool="Compute-ResourcePool" -folder="Templates" -options=${HAPROXY}.json ${HAPROXY}.ova
  govc snapshot.create -vm ${HAPROXY} root
  govc vm.markastemplate ${HAPROXY}
fi


#!/bin/bash

set -e

USER=ubuntu

KEY=$(cat ~/.ssh/id_rsa.pub | awk '{ print $1" "$2 }' | tr ' ' '_')

if [ -z "${SERVER+x}" ]; then
	SERVER=$(scw create \
        	--commercial-type=C2S \
        	--name="[live] LineageBuilder" \
        	--volume=200GB \
        	--env="AUTHORIZED_KEY=${KEY}" \
        	ubuntu-bionic)
	scw start "${SERVER}"
fi

scw exec -w "${SERVER}" uname -a
echo ${SERVER} is started

HDIR=$(scw exec -w --user="${USER}" "${SERVER}" 'printf $HOME')
echo "${HDIR}" is the working directory

scw exec "${SERVER}" mkfs.ext4 /dev/nbd1
scw exec --user="${USER}" "${SERVER}" 'mkdir -p $HOME/android/lineage'

scw exec "${SERVER}" mount /dev/nbd1 "${HDIR}"/android/lineage
scw exec "${SERVER}" chown -R ${USER}:${USER} "${HDIR}"/android/lineage

scw cp ./build-lineage.sh "${SERVER}":"${HDIR}"/
scw cp ./android-certs.tgz "${SERVER}":"${HDIR}"/
scw exec "${SERVER}" chown -R ${USER}:${USER} "${HDIR}"/build-lineage.sh "${HDIR}"/android-certs.tgz
scw exec "${SERVER}" 'DEBIAN_FRONTEND=noninteractive apt install -yq sudo'
scw exec --user="${USER}" "${SERVER}" 'chmod +x $HOME/build-lineage.sh'
scw exec --user="${USER}" "${SERVER}" 'tmux new -d sudo $HOME/build-lineage.sh'

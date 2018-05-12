#!/bin/bash
HA_VERSION=$(curl -Ls https://raw.githubusercontent.com/home-assistant/hassio/master/version.json | jq -r ".homeassistant")
NERO_HA_VERSION=$(cd "$(dirname "$0")"; grep "FROM" Dockerfile | awk -F ":" '{print $2}')
cd "$(dirname "$0")"

function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }
function chack_hub() { test "$(curl -s -S 'https://registry.hub.docker.com/v2/repositories/homeassistant/qemux86-64-homeassistant/tags/' | jq '."results"[]["name"]' |sort |grep "${HA_VERSION}")"; }

if version_gt ${HA_VERSION} ${NERO_HA_VERSION} && chack_hub ; then
	git pull
	sed -i "s/${NERO_HA_VERSION}/${HA_VERSION}/" Dockerfile
	git commit -m "upgrade ${HA_VERSION}" Dockerfile
	git push origin master
	git tag ${HA_VERSION}
	git push origin ${HA_VERSION}
fi

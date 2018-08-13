#!/bin/bash
if [[ -z $1  ]]; then
	HA_VERSION=$(curl -Ls --socks5 127.0.0.1:1080 https://s3.amazonaws.com/hassio-version/stable.json | jq -r '.homeassistant.default')
else
	HA_VERSION="$1"
fi
NERO_HA_VERSION=$(cd "$(dirname "$0")"; grep "FROM" Dockerfile | awk -F ":" '{print $2}')
cd "$(dirname "$0")"

function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }
function chack_hub() { test "$(curl -s -S 'https://registry.hub.docker.com/v2/repositories/homeassistant/qemux86-64-homeassistant/tags/' | jq '."results"[]["name"]' |sort |grep -w "${HA_VERSION}")"; }

if version_gt ${HA_VERSION} ${NERO_HA_VERSION} && chack_hub ; then
	sed -i "s/${NERO_HA_VERSION}/${HA_VERSION}/" Dockerfile
	git commit -m "upgrade ${HA_VERSION}" Dockerfile stable.json
	git tag ${HA_VERSION}
	git push origin ${HA_VERSION}
	git push origin master
fi

# update stable.json
new_stable=$(curl -Ls --socks5 127.0.0.1:1080 https://s3.amazonaws.com/hassio-version/stable.json)
new_md5=$(echo "${new_stable}" | md5sum)
old_md5=$(cat stable.json | md5sum)
if [[ ${new_md5} != ${old_md5} ]]; then
	echo "${new_stable}" > stable.json
fi

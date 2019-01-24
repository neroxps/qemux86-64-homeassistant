#!/bin/bash

# update stable.jsons
new_stable=$(curl -Ls --socks5 127.0.0.1:1080 https://s3.amazonaws.com/hassio-version/stable.json)
new_md5=$(echo "${new_stable}" | md5sum)
old_md5=$(cat stable.json | md5sum)
if [[ ${new_md5} != ${old_md5} ]]; then
	echo "${new_stable}" > stable.json
fi

# home-assistant update
if [[ -z $1  ]]; then
	HA_VERSION=$(echo "${new_stable}" | jq -r '.homeassistant.default')
else
	HA_VERSION="$1"
fi
NERO_HA_VERSION=$(cd "$(dirname "$0")"; grep "FROM" Dockerfile | awk -F ":" '{print $2}')
cd "$(dirname "$0")"

function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }
function chack_hub() { test "$(curl -s -S 'https://registry.hub.docker.com/v2/repositories/homeassistant/qemux86-64-homeassistant/tags/' | jq '."results"[]["name"]' |sort |grep -w "${HA_VERSION}")"; }

if version_gt ${HA_VERSION} ${NERO_HA_VERSION} ; then
	if chack_hub ; then
		sed -i "s/${NERO_HA_VERSION}/${HA_VERSION}/" Dockerfile
		git commit -m "upgrade ${HA_VERSION}" Dockerfile stable.json
		git tag ${HA_VERSION}
		git push origin ${HA_VERSION}
		git push origin master
	else
		echo '官方未推送版本至 Hub，升级取消。'
	fi
else
	echo "当版本: ${NERO_HA_VERSION} 最新版本: ${HA_VERSION} 无需升级。"
fi

#!/bin/bash -e

plugin=plugin.nakama
vendor=com.manicapps
(
    cd "$(dirname "$0")/lua"
    d="$HOME/Solar2DPlugins/$vendor/$plugin/2017.3032/lua"
    mkdir -p "$d"
    COPYFILE_DISABLE=true tar -cf "$d/data.tgz" --exclude="*.hg*" --exclude "*.git*"  plugin
)
rm -f ~/Library/Application\ Support/Corona/Simulator/Plugins/catalog.json
echo "[\"$plugin\"] = { publisherId = \"$vendor\", },"
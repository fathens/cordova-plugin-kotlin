#!/bin/bash
set -eu

plugin_id=$1

prefix="$(cd $(dirname $0); pwd)/after_plugin_install"

subrun() {
    time ${prefix}-$1.sh "$plugin_id"
}

cat <<EOF | while read name; do subrun "$name"; done
build_gradle
EOF

#!/usr/bin/env bash

set -Eeuo pipefail

# usage: curlx <url> <file name>
if [[ $# -ne 2 || -z "$1" || -z "$2" ]]; then
    echo "Usage: $0 <url> <file name>" >&2
    exit 2
fi

curl --fail --location --show-error --retry 3 --retry-all-errors --continue-at - --progress-bar "$1" --output "$2"

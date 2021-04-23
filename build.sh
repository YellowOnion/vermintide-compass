#!/usr/bin/env bash
set -euo pipefail

build() {

        7z a ../Compass.zip *
        mv ../Compass.zip ../Compass.mod
        cp ../Compass.mod ./
}

loop() {
    while read dir events fname; do
        echo "file change $fname; rebuilding"
        build
    done
}
build
inotifywait -q -e close_write -rm . | loop

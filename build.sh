#!/usr/bin/env bash
set -euo pipefail


loop() {
    while read dir events fname; do
        echo "file change $fname; rebuilding"
        7z a ../Compass.zip *
        mv ../Compass.zip ../Compass.mod
    done
}

inotifywait -q -e close_write -rm . | loop

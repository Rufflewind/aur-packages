#!/bin/bash
set -eux
mkdir -p /tmp/aur-packages/gitit-test
(
    cd /tmp/aur-packages/gitit-test
    (sleep 2 && curl -L http://127.0.0.1:9000 | md5sum) &
    timeout 4 /usr/bin/gitit -l 127.0.0.1 -p 9000 && :
    if [ $? -ne 124 ]; then
        echo >&2 test failed
        exit 1
    fi
)

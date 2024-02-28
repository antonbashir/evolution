#!/bin/bash

for module in */ ; do
    if [ -f "$module/ffigen.sh" ]; then
        echo "Generate bindings for $module"
        cd $module && bash -c ./ffigen.sh && cd ..
    fi
done
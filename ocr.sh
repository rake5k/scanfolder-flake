#!/usr/bin/env bash

set -euo pipefail

export GLOBIGNORE='*_ocr.pdf'

echo 'Running ocr on pdf files...'
for file in *.pdf
do
    if [[ -e "$file" ]]
    then
        echo "| $file"
        pdfsandwich -quiet -lang deu -rgb "$file"
    fi
done
echo 'done.'


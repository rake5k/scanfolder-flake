#!/usr/bin/env bash

set -euo pipefail

DATE="$(date '+%F')"
TIME="$(date '+%T')"
DIR="${DATE}"
FILE="${DIR}/hpscan_${DATE}T${TIME}.pdf"

mkdir -p "${DIR}"
hp-scan -d "hpaio:/net/Officejet_Pro_8600?hostname=pr-hp-chr" -f "${FILE}" --size=a4 ${@}
echo "Running OCR on file ${FILE}..."
pdfsandwich -quiet -lang deu -rgb "${FILE}"
echo "done."

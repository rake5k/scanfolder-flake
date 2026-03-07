#!/usr/bin/env bash

set -euo pipefail

DATE="$(date '+%F')"
TIME="$(date '+%T')"
DIR="${DATE}"
FILE="${DIR}/hpscan_${DATE}T${TIME}.pdf"

mkdir -p "${DIR}"

# Sane always fails after first page
# scanimage --device-name='hpaio:/net/Officejet_Pro_8600?hostname=pr-hp-chr' --format='pdf' --resolution=300 --batch="${DIR}/scanimage_${DATE}T${TIME}.pdf" --batch-prompt

_read() {
    RESET="\033[0m"
    BOLD="\033[1m"
    PURPLE="\033[35m"

    local prompt="${1}"
    local default="${2:-}"

    _print_default_value() {
        [[ -n "${default}" ]] && echo " [${default}]"
    }

    local answer
    local default_value
    # shellcheck disable=SC2311
    default_value="$(_print_default_value)"
    read -rp "$(echo -e "\n${BOLD}${PURPLE}${prompt}${RESET}${default_value} ")" answer

    local answer_filled="${answer:-"${default}"}"

    echo "${answer_filled}"
}

_read_boolean() {
    local prompt="${1}"
    local default="${2:-}"

    _cap_if_default() {
        local low="${1,,}"
        local cap="${1^^}"

        [[ "${default^^}" = "${cap}" ]] && echo "${cap}" || echo "${low}"
    }

    local yes
    # shellcheck disable=SC2311
    yes="$(_cap_if_default "y")"
    local no
    # shellcheck disable=SC2311
    no="$(_cap_if_default "n")"
    local answer
    # shellcheck disable=SC2311
    answer="$(_read "${prompt} (${yes}/${no})")"

    local answer_filled="${answer:-"${default}"}"

    if [[ "${answer_filled^^}" =~ (Y|N) ]]; then
        [[ "${answer_filled^^}" = "Y" ]]
    else
        _read_boolean "${@}"
    fi
}

while _read_boolean "Scan another page?" Y
do
  TMP_FILE="${DIR}/hpscan_${DATE}T${TIME}_tmp.pdf"
  hp-scan -d 'hpaio:/net/Officejet_Pro_8600?hostname=pr-hp-chr.lan.harke.ch' -f "${TMP_FILE}" --size='a4' ${@}

  if [[ -f "${FILE}" ]]; then
    INPUT_FILE="${DIR}/hpscan_${DATE}T${TIME}_input.pdf"
    mv "${FILE}" "${INPUT_FILE}"
    pdfunite "${INPUT_FILE}" "${TMP_FILE}" "${FILE}"
    rm "${INPUT_FILE}" "${TMP_FILE}"
  else
    mv "${TMP_FILE}" "${FILE}"
  fi

  #echo "Running OCR on file ${FILE}..."
  #pdfsandwich -quiet -lang deu -rgb "${FILE}"
done

echo "done."

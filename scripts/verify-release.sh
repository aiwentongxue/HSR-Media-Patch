#!/bin/zsh
set -euo pipefail

ROOT="${0:A:h:h}"
ZIP="${1:-${ROOT}/dist/HSR-Media-Patch-v1.0.0.zip}"
TMP="$(/usr/bin/mktemp -d -t hsr-media-release.XXXXXX)"

[[ -f "${ZIP}" ]] || {
  print -u2 "Missing ZIP: ${ZIP}"
  exit 1
}

/usr/bin/ditto -x -k "${ZIP}" "${TMP}"
PACKAGE="$(/usr/bin/find "${TMP}" -maxdepth 1 -type d -name 'HSR-Media-Patch-v*' -print -quit)"
[[ -d "${PACKAGE}" ]] || {
  print -u2 "Package root was not found."
  exit 1
}

[[ -x "${PACKAGE}/一键安装补丁.command" ]]
[[ -x "${PACKAGE}/一键恢复.command" ]]
[[ -x "${PACKAGE}/scripts/hsr-media-patch" ]]
[[ -x "${PACKAGE}/tools/dlopen-probe" ]]
[[ -x "${PACKAGE}/tools/gst-probe" ]]
[[ -f "${PACKAGE}/LICENSE" ]]
[[ -f "${PACKAGE}/SOURCE_OFFER.md" ]]
[[ -f "${PACKAGE}/THIRD_PARTY_NOTICES.md" ]]
[[ -f "${PACKAGE}/licenses/LGPL-2.1.txt" ]]
[[ -f "${PACKAGE}/licenses/GPL-2.0.txt" ]]

EXPECTED="$(/usr/bin/tr -d '[:space:]' < "${PACKAGE}/payload/GStreamer.framework.tar.xz.sha256")"
ACTUAL="$(/usr/bin/shasum -a 256 "${PACKAGE}/payload/GStreamer.framework.tar.xz" | awk '{print $1}')"
[[ "${EXPECTED}" == "${ACTUAL}" ]]

zsh -n "${PACKAGE}/scripts/hsr-media-patch"
"${PACKAGE}/scripts/hsr-media-patch" detect >/dev/null
"${PACKAGE}/scripts/hsr-media-patch" diagnose >/tmp/hsr-media-release-diagnose.txt

print "Release ZIP verification passed."
print "Root: ${PACKAGE}"
print "Payload SHA-256: ${ACTUAL}"
print "/tmp/hsr-media-release-diagnose.txt"


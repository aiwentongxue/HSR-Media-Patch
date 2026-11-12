#!/bin/zsh
set -euo pipefail

ROOT="${0:A:h:h}"
PAYLOAD="${ROOT}/payload/GStreamer.framework.tar.xz"
HASH_FILE="${PAYLOAD}.sha256"

for script in \
  "${ROOT}/一键安装补丁.command" \
  "${ROOT}/一键恢复.command" \
  "${ROOT}/scripts/hsr-media-patch" \
  "${ROOT}/scripts/"*.sh; do
  echo "zsh -n ${script:t}"
  zsh -n "${script}"
done

python3 -m py_compile "${ROOT}/scripts/patch-rank.py"

xcrun clang -arch x86_64 -std=c11 -Wall -Wextra -Werror \
  -c "${ROOT}/tools/dlopen-probe.c" -o /tmp/hsr-dlopen-probe.o
xcrun clang -arch x86_64 -std=c11 -Wall -Wextra -Werror \
  -c "${ROOT}/tools/gst-probe.c" -o /tmp/hsr-gst-probe.o

if [[ -f "${PAYLOAD}" && -f "${HASH_FILE}" ]]; then
  EXPECTED="$(tr -d '[:space:]' < "${HASH_FILE}")"
  ACTUAL="$(shasum -a 256 "${PAYLOAD}" | awk '{print $1}')"
  [[ "${EXPECTED}" == "${ACTUAL}" ]]
  echo "Payload SHA-256: ${ACTUAL}"
else
  echo "Generated payload is absent; source checkout checks will continue."
fi

generated_tools=0
for tool in "${ROOT}/tools/dlopen-probe" "${ROOT}/tools/gst-probe"; do
  if [[ -e "${tool}" ]]; then
    [[ -x "${tool}" ]]
    [[ "$(lipo -archs "${tool}")" == *x86_64* ]]
    codesign --verify --strict "${tool}"
    generated_tools=1
  fi
done
if (( generated_tools == 0 )); then
  echo "Generated probe tools are absent; source compilation checks passed."
fi

[[ "$("${ROOT}/scripts/hsr-media-patch" detect)" == *"26.3.0.39832"* ]]
[[ "$("${ROOT}/scripts/hsr-media-patch" detect)" == *"27.0.0.41073"* ]]

echo "Static tests passed."


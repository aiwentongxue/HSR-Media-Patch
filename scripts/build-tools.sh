#!/bin/zsh
set -euo pipefail

ROOT="${0:A:h:h}"

mkdir -p "${ROOT}/tools"

xcrun clang -arch x86_64 -std=c11 -O2 \
  "${ROOT}/tools/dlopen-probe.c" \
  -o "${ROOT}/tools/dlopen-probe"

xcrun clang -arch x86_64 -std=c11 -O2 \
  "${ROOT}/tools/gst-probe.c" \
  -o "${ROOT}/tools/gst-probe"

for tool in "${ROOT}/tools/dlopen-probe" "${ROOT}/tools/gst-probe"; do
  /usr/bin/xattr -cr "${tool}"
  /usr/bin/codesign --force --sign - "${tool}"
  /usr/bin/codesign --verify --strict "${tool}"
  /usr/bin/lipo -archs "${tool}"
done


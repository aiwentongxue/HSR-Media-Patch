#!/bin/zsh
set -euo pipefail

ROOT="${0:A:h:h}"
WORK="${ROOT}/.work"
CACHE="${WORK}/cache"
EXTRACT="${WORK}/extract"
FRAMEWORK="${WORK}/GStreamer.framework"
PAYLOAD="${ROOT}/payload/GStreamer.framework.tar.xz"
HASH_FILE="${PAYLOAD}.sha256"
source "${ROOT}/payload/framework-source.env"

mkdir -p "${CACHE}" "${PAYLOAD:h}"
SOURCE_ARCHIVE="${CACHE}/${FRAMEWORK_ARCHIVE_NAME}"

if [[ ! -f "${SOURCE_ARCHIVE}" ]]; then
  print "Downloading GStreamer ${FRAMEWORK_VERSION}"
  /usr/bin/curl --http1.1 --retry 3 --retry-delay 2 -L --fail \
    "${FRAMEWORK_URL}" -o "${SOURCE_ARCHIVE}"
fi

actual="$(/usr/bin/shasum -a 256 "${SOURCE_ARCHIVE}" | awk '{print $1}')"
[[ "${actual}" == "${FRAMEWORK_SHA256}" ]] || {
  print -u2 "Downloaded framework hash mismatch"
  print -u2 "expected=${FRAMEWORK_SHA256}"
  print -u2 "actual=${actual}"
  exit 1
}

if [[ -d "${EXTRACT}" ]]; then
  /bin/mv "${EXTRACT}" "${WORK}/extract.previous-$(date +%Y%m%d-%H%M%S)"
fi
mkdir -p "${EXTRACT}"
COPYFILE_DISABLE=1 /usr/bin/tar -xJf "${SOURCE_ARCHIVE}" -C "${EXTRACT}"

FOUND="$(/usr/bin/find "${EXTRACT}" -type d -name 'GStreamer.framework' -print -quit)"
[[ -n "${FOUND}" ]] || {
  print -u2 "GStreamer.framework was not found in the source archive."
  exit 1
}

if [[ -e "${FRAMEWORK}" ]]; then
  /bin/mv "${FRAMEWORK}" "${WORK}/GStreamer.framework.previous-$(date +%Y%m%d-%H%M%S)"
fi
/usr/bin/ditto --norsrc --noextattr "${FOUND}" "${FRAMEWORK}"

PLUGIN="${FRAMEWORK}/Versions/Current/lib/gstreamer-1.0/libgstlibav.dylib"
[[ -f "${PLUGIN}" ]] || {
  print -u2 "libgstlibav.dylib is missing from the framework."
  exit 1
}

python3 "${ROOT}/scripts/patch-rank.py" "${PLUGIN}"
/usr/bin/xattr -cr "${PLUGIN}"
/usr/bin/codesign --force --sign - "${PLUGIN}"
/usr/bin/codesign --verify --strict "${PLUGIN}"

[[ "$(/usr/bin/lipo -archs "${PLUGIN}")" == *x86_64* ]] || {
  print -u2 "libgstlibav.dylib is not x86_64."
  exit 1
}

COPYFILE_DISABLE=1 /usr/bin/tar -cJf "${PAYLOAD}" -C "${WORK}" GStreamer.framework
/usr/bin/shasum -a 256 "${PAYLOAD}" | awk '{print $1}' > "${HASH_FILE}"

"${ROOT}/scripts/build-tools.sh"

print "Built payload: ${PAYLOAD}"
hash_value="$(cat "${HASH_FILE}")"
print "SHA-256: ${hash_value}"


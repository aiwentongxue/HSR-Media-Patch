#!/bin/zsh
set -euo pipefail

ROOT="${0:A:h:h}"
VERSION="${1:-1.0.0}"
DIST="${ROOT}/dist"
STAGE="${DIST}/HSR-Media-Patch-v${VERSION}"
ZIP="${DIST}/HSR-Media-Patch-v${VERSION}.zip"

"${ROOT}/scripts/build-payload.sh"

if [[ -e "${STAGE}" ]]; then
  /bin/mv "${STAGE}" "${DIST}/HSR-Media-Patch-v${VERSION}.previous-$(date +%Y%m%d-%H%M%S)"
fi
mkdir -p "${STAGE}/payload" "${STAGE}/scripts" "${STAGE}/tools" "${STAGE}/docs"

for item in \
  README.md LICENSE THIRD_PARTY_NOTICES.md \
  一键安装补丁.command 一键恢复.command; do
  /usr/bin/ditto --norsrc --noextattr "${ROOT}/${item}" "${STAGE}/${item}"
done

for item in scripts/hsr-media-patch scripts/patch-rank.py; do
  /usr/bin/ditto --norsrc --noextattr "${ROOT}/${item}" "${STAGE}/${item}"
done

for item in tools/dlopen-probe tools/gst-probe; do
  /usr/bin/ditto --norsrc --noextattr "${ROOT}/${item}" "${STAGE}/${item}"
done

for item in payload/GStreamer.framework.tar.xz payload/GStreamer.framework.tar.xz.sha256 payload/framework-source.env; do
  /usr/bin/ditto --norsrc --noextattr "${ROOT}/${item}" "${STAGE}/${item}"
done

if [[ -f "${ROOT}/docs/VERIFICATION.md" ]]; then
  /usr/bin/ditto --norsrc --noextattr "${ROOT}/docs/VERIFICATION.md" "${STAGE}/VERIFICATION.md"
fi
if [[ -d "${ROOT}/docs/verification" ]]; then
  /usr/bin/ditto --norsrc --noextattr "${ROOT}/docs/verification" "${STAGE}/docs/verification"
fi

chmod +x \
  "${STAGE}/一键安装补丁.command" \
  "${STAGE}/一键恢复.command" \
  "${STAGE}/scripts/hsr-media-patch" \
  "${STAGE}/tools/dlopen-probe" \
  "${STAGE}/tools/gst-probe"

if [[ -e "${ZIP}" ]]; then
  /bin/mv "${ZIP}" "${DIST}/HSR-Media-Patch-v${VERSION}.previous-$(date +%Y%m%d-%H%M%S).zip"
fi
/usr/bin/ditto -c -k --norsrc --noextattr --keepParent "${STAGE}" "${ZIP}"

/usr/bin/ditto --norsrc --noextattr "${ROOT}/THIRD_PARTY_NOTICES.md" \
  "${DIST}/THIRD_PARTY_NOTICES.md"
if [[ -f "${ROOT}/docs/VERIFICATION.md" ]]; then
  /usr/bin/ditto --norsrc --noextattr "${ROOT}/docs/VERIFICATION.md" \
    "${DIST}/VERIFICATION.md"
fi

cd "${DIST}"
{
  /usr/bin/shasum -a 256 "${ZIP:t}"
  /usr/bin/shasum -a 256 VERIFICATION.md
  /usr/bin/shasum -a 256 THIRD_PARTY_NOTICES.md
} > SHA256SUMS

print "Built release: ${ZIP}"
cat "${DIST}/SHA256SUMS"


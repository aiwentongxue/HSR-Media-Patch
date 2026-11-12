#!/bin/zsh
set -euo pipefail

ROOT="${0:A:h}"
exec "${ROOT}/scripts/hsr-media-patch" menu-restore "$@"

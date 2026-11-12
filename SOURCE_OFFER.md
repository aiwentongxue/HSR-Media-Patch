# Third-Party Source And Build Information

本文档对应 `HSR-Media-Patch v1.0.0` Release。

## Bundled runtime

Release 中的 `payload/GStreamer.framework.tar.xz` 来自以下固定上游资产：

- Repository: `Sikarugir-App/gstreamer`
- Tag: `1.28.1`
- Asset:
  `gstreamer-1.0-1.28.1-x86_64.tar.xz`
- SHA-256:
  `1c2b47d360306e04a9dda99c9974469ffeeb7119fdcd047a3c2a368df3701aaa`
- Release:
  <https://github.com/Sikarugir-App/gstreamer/releases/tag/1.28.1>
- Corresponding source tree:
  <https://github.com/Sikarugir-App/gstreamer/tree/1.28.1>

该 tag 包含 GStreamer monorepo 的构建脚本和相应 CMake/Meson 配置。组成
runtime 的 GStreamer 子项目在 `subprojects/` 下保留各自的 `COPYING`
或 `LICENSE` 文件。

## FFmpeg

GStreamer `1.28.1` 中的 `subprojects/FFmpeg.wrap` 使用：

- Repository:
  `https://gitlab.freedesktop.org/gstreamer/meson-ports/ffmpeg.git`
- Revision label: `meson-7.1.1`
- Source tree:
  <https://gitlab.freedesktop.org/gstreamer/meson-ports/ffmpeg/-/tree/meson-7.1.1>

随包 `libavcodec.61.dylib` 的构建标识为 `FFmpeg version f856235`，并报告
`libavcodec license: LGPL version 2.1 or later`。

## Local modification

Compared with the upstream runtime, `libgstlibav.dylib` has one deterministic
binary modification:

- Offset: `0x12FEF`
- H.264 decoder rank: `256` to `2147483647`
- Patch program: `scripts/patch-rank.py`

The script rejects unexpected bytes before writing. It does not patch FFmpeg
algorithm code or change component licensing text.

To reproduce the runtime:

```bash
./scripts/build-payload.sh
```

To rebuild the complete Release ZIP:

```bash
./scripts/build-release.sh 1.0.0
./scripts/verify-release.sh dist/HSR-Media-Patch-v1.0.0.zip
```

## Replacement

The patched framework is installed as a separate app copy. A user may replace
`GStreamer.framework` and `libgstlibav.dylib` with a compatible self-built
runtime, then re-sign the copied CrossOver App. No proprietary files from the
game or CrossOver are required to rebuild the third-party runtime.

## License texts

- `licenses/LGPL-2.1.txt`
- `licenses/GPL-2.0.txt`

Further upstream notice details are in `THIRD_PARTY_NOTICES.md`.

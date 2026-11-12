# Third-Party Notices

本项目的自有脚本与文档使用 MIT License。第三方组件仍归各自作者所有，并
继续适用其原始许可证。

发布包内含由 [Sikarugir-App/gstreamer](https://github.com/Sikarugir-App/gstreamer)
提供的 x86_64 GStreamer 1.28.1 runtime。该 runtime 包含 GStreamer、GStreamer
plugins、FFmpeg/libav 以及其他依赖库。

- 预构建包版本固定为 tag `1.28.1`。
- `gstreamer-1.0-1.28.1-x86_64.tar.xz` 的 SHA-256 为
  `1c2b47d360306e04a9dda99c9974469ffeeb7119fdcd047a3c2a368df3701aaa`。
- FFmpeg 库内部构建标识为 `f856235`，GStreamer tag `1.28.1` 的
  `FFmpeg.wrap` 固定使用 `meson-ports/ffmpeg` 的 `meson-7.1.1` 分支。
- runtime 中包含 `gst-plugins-ugly` 的模块。部分模块可能受 GPL-2.0 或
  GPL-2.0-or-later 条款约束，因此发布同时提供 GPL-2.0 许可证文本。

许可证：

- GStreamer：LGPL-2.1-or-later。
- FFmpeg/libav 库：此构建报告 `libavcodec license: LGPL version 2.1 or later`。
- GStreamer plugins：各插件沿用其源文件中的许可证，可能包括 LGPL-2.1-or-later
  和 GPL-2.0-or-later。
- runtime 中其他依赖库沿用各自上游许可证。

项目内提供以下许可证文本：

- `licenses/LGPL-2.1.txt`
- `licenses/GPL-2.0.txt`

源码与构建信息：

- GStreamer 项目：https://gstreamer.freedesktop.org/
- GStreamer 源码与许可证：https://gitlab.freedesktop.org/gstreamer/gstreamer
- 本发布包对应的预构建源码 tag：
  https://github.com/Sikarugir-App/gstreamer/tree/1.28.1
- 对应源码归档：
  https://github.com/Sikarugir-App/gstreamer/archive/refs/tags/1.28.1.tar.gz
- FFmpeg 项目：https://ffmpeg.org/
- FFmpeg 源码与许可证：https://ffmpeg.org/download.html
- 预构建包来源：https://github.com/Sikarugir-App/gstreamer
- 本构建使用的 FFmpeg 源码分支：
  https://gitlab.freedesktop.org/gstreamer/meson-ports/ffmpeg/-/tree/meson-7.1.1

各组件保留其原始版权与许可证。本工具不修改这些组件内部的许可证文本，
也不声明拥有这些第三方组件的版权。

## Binary modification

发布包对 `libgstlibav.dylib` 做了一项二进制修改：

- 文件偏移：`0x12FEF`
- 修改：H.264 decoder rank 从 `256` 改为 `2147483647`
- 可复现脚本：`scripts/patch-rank.py`

这是一处运行时优先级修复，不改变算法实现。用户可以使用项目提供的源码地址
自行重新编译，并用自己构建的兼容 `libgstlibav.dylib` 替换发布包内对应文件。

完整来源说明和重新构建方法见 `SOURCE_OFFER.md`。


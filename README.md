# HSR Media Patch

用于修复 CrossOver 下《崩坏：星穹铁道》高分辨率 H.264 过场动画黑屏的问题。

本工具按 HexAid 的思路替换 CrossOver App 内的整套 GStreamer/FFmpeg 运行时，并为 FFmpeg H.264 解码器设置最高优先级。它只修改 CrossOver App 的运行库：

- 不修改 `HSR-CN` 容器。
- 不修改 Windows Media Foundation DLL。
- 不修改游戏文件。
- 不修改 `/etc/hosts`。

## 支持版本

| CrossOver 产品 | 兼容版本 | 运行时目录 |
| --- | --- | --- |
| 正式版 CrossOver | `26.3.0.39832` | `lib64` |
| CrossOver Preview | `27.0.0.41073` | `lib/x86_64` |

当前状态：

- Preview `27.0.0.41073`：已实际验证高分辨率过场画面正常。
- 正式版 `26.3.0.39832`：已验证安装、RPATH、签名、framework 加载和 H.264 rank；实际游戏过场等待发布者复测。

其他版本只有在目录、架构、依赖和插件布局检查全部通过后，才允许以“实验性”模式安装。

## 推荐使用流程

1. 完全退出 CrossOver，关闭所有正在运行的游戏。
2. 双击 `一键安装补丁.command`。
3. 在终端菜单中选择 `1. 检测并创建安全副本`。
4. 输入 Mac 管理员密码。脚本只会向 `/Applications` 复制和修改新的 `*-HSR-MediaFix.app` 副本。
5. 安装完成后，从 Finder 或启动台打开新生成的修复版 App：
   - 正式版：`CrossOver-HSR-MediaFix.app`
   - Preview：`CrossOver Preview-HSR-MediaFix.app`
6. 按平时的方式使用 Mac 游戏工具箱的 HoYoGames 启动帮助。
7. 让 hosts 屏蔽倒计时完整结束。
8. 在修复版 CrossOver 中对 `HSR-CN` 运行原始 `C:\HSR-Mac.bat`。
9. 游戏进入登录界面后立即恢复 hosts。

原始 CrossOver App 不会被修改。默认安全副本会同时保留原 App 的签名状态。

## 恢复与删除

双击 `一键恢复.command`，或在安装脚本菜单中选择 `4. 恢复/移除补丁`。

- 修复副本：直接从 `/Applications` 删除，原始 App 始终不受影响。
- 原位修改：恢复到安装前的 CrossOver 运行库。由于官方签名无法恢复，恢复后的 App 会使用本地 ad-hoc 签名。

## 没有修复成功时

先运行菜单中的 `2. 诊断当前环境`。诊断结果会显示：

- 检测到的 CrossOver 版本和运行时路径。
- `winegstreamer.so` 架构与依赖。
- `avdec_h264`、`vtdec_hw` 和 `vtdec` 的解码优先级。
- App 签名、补丁状态和最近的安装日志。

日志位于：

```text
~/Library/Logs/HSR-Media-Patch/
```

备份与安装清单位于：

```text
~/Library/Application Support/HSR-Media-Patch/Backups/
```

常见问题：

- **macOS 阻止打开 `.command`**：右键选择“打开”；仍被阻止时，在终端运行 `xattr -cr HSR-Media-Patch-v1.0.0`。
- **提示 App 正在运行**：退出 CrossOver 和所有 Wine 游戏后重试。
- **版本被拒绝**：当前构建只完整验证了上表中的两个版本。实验版本必须通过结构检查，并明确输入 `YES`。
- **签名验证失败**：工具会停止并保留备份，不会继续覆盖。
- **游戏仍黑屏**：运行诊断，并确认启动的是 `*-HSR-MediaFix.app`，而不是原始 CrossOver。

## GitHub 发布包

发布 ZIP 内包含：

```text
一键安装补丁.command
一键恢复.command
README.md
payload/GStreamer.framework.tar.xz
tools/dlopen-probe
tools/gst-probe
scripts/hsr-media-patch
```

同目录发布以下校验文件：

```text
SHA256SUMS
VERIFICATION.md
THIRD_PARTY_NOTICES.md
```

源码仓库不跟踪 framework 压缩包。`scripts/build-release.sh` 会从固定来源下载并校验框架，再生成最终 Release ZIP。

源码维护者重新生成发布包：

```bash
./scripts/build-release.sh 1.0.0
./scripts/verify-release.sh dist/HSR-Media-Patch-v1.0.0.zip
```

构建环境需要 macOS、Xcode Command Line Tools、`curl`、`tar` 和 `codesign`。

## 技术说明

Preview 原生 GStreamer 不包含 `libgstlibav`。高分辨率 H.264 会优先进入 rank 257 的 `vtdec_hw`，随后 Media Foundation 无法把转换后的帧正确回传，出现 `IMF2DBuffer2` 和 `Cannot read 7372800 bytes` 错误。

补丁提供：

- GStreamer 1.28.1 x86_64 framework。
- FFmpeg `libgstlibav` 及依赖。
- H.264 软件解码器 rank `2147483647`，高于 `vtdec_hw`。
- 针对两版 CrossOver 分别配置的正确 RPATH。

## 许可证

本仓库脚本和文档采用 MIT License。GStreamer、FFmpeg 及其他第三方组件遵循各自许可证，详见 `THIRD_PARTY_NOTICES.md`。


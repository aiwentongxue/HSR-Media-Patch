# Verification Record

## Preview 20261111 / 27.0.0.41303

2026-11-18 在 Apple Silicon Mac（macOS 27.3）上测试 `win64` 容器。

- 使用默认副本模式安装，App 签名严格校验和 `winegstreamer.so` 的 `dlopen` 均通过。
- 在隔离容器中用 Wine 的 `IMFSourceReader` 读取 2560×1440 H.264 测试片。原版使用 `vtdec_hw`，修补版使用 `avdec_h264`。两次均输出 60 帧，每帧 7,372,800 字节，59 帧与前一帧内容不同。
- 使用同一游戏副本直接启动时，原版和修补版均在进入游戏前遇到 `MHYPBase.dll` 访问冲突（`0xc0000005`）。随后用户按平时的流程从修补版启动游戏，并确认游戏内视频动画正常播放。

## 2026-11-12 验证记录

### Preview 27.0.0.41073

状态：实际过场播放通过。

- 原 App：`/Applications/CrossOver Preview.app`
- 修复副本：`CrossOver Preview-HSR-MediaFix.app`
- framework：GStreamer 1.28.1 x86_64
- `winegstreamer.so`：`dlopen` 成功
- `libgstlibav.dylib`：加载成功
- `avdec_h264` rank：`2147483647`
- App ad-hoc 签名：strict verify 通过
- 原 `winegstreamer.so` SHA-256 保持不变
- `HSR-CN/cxbottle.conf` SHA-256 保持不变
- 实际进入游戏并播放 2560×1440 级别过场：通过
- 画面证据：用户提供的高分辨率过场截图，画面、粒子和角色均正常显示。

### Stable CrossOver 26.3.0.39832

状态：实际过场播放通过。

- 运行时目录：`lib64`
- RPATH：`@loader_path/../../../lib64/GStreamer.framework/Versions/Current/lib`
- `winegstreamer.so`：`dlopen` 成功
- `libgstlibav.dylib`：加载成功
- `avdec_h264` rank：`2147483647`
- App ad-hoc 签名：strict verify 通过
- 复制副本移除与备份清单删除：通过
- 原 App 签名保持不变
- 实际进入游戏并播放 2560×1440 级别过场：通过

### 恢复验证

- Preview copy-mode：安装、签名、framework/rank 验证、副本移除通过。
- Stable copy-mode：安装、签名、framework/rank 验证、副本移除通过。
- 两个版本均已由发布者使用修复副本实际进入游戏并测试高分辨率过场。
- In-place 模式：由用户按 README 在关闭游戏后复测。


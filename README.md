# Wizard Player

一个支持在线视频和 BT 种子播放的 Flutter 跨平台应用。

## 功能特性

- 🎬 在线视频播放
- 🧲 BT 种子/磁链播放（支持边下边播）
- 📺 番剧资源聚合搜索
- ⏯️ 全功能视频播放器
- 📱 跨平台支持：Android、iOS、Windows、macOS、Linux
- 🎨 自定义播放器 UI（进度条、控制按钮等）
- 🔊 音量控制、倍速播放、快进快退

## 快速开始

```bash
# 安装依赖
flutter pub get

# 运行应用（Windows）
flutter run -d windows

# 运行应用（Android）
flutter run -d android

# 运行应用（macOS）
flutter run -d macos
```

## 使用说明

### 测试视频
在【发现】页面可以找到测试视频，方便快速测试播放器功能。

### BT 播放
应用会优先使用在线源，当找不到在线源时会自动切换到 BT 源播放。

### 播放器控制
- **播放/暂停**：点击视频中央或控制栏按钮
- **快进/快退**：双击左右两侧区域，或左右滑动
- **音量控制**：点击音量图标切换静音
- **倍速播放**：点击倍速图标选择播放速度
- **全屏模式**：点击全屏按钮进入/退出全屏

## Packages 模块说明

### wizard_player_danmaku
弹幕系统，为 WizardPlayer 提供弹幕解析和渲染功能。

### wizard_player_datasource
数据源模块，整合多个视频源（Bangumi、Mikan、DMHY、AniSpace），提供统一的数据获取接口。

### wizard_player_media
跨平台视频播放器抽象库，基于 **media_kit**（libmpv）实现，提供：
- 统一的播放器接口 `WizardPlayer`
- 自定义播放器 Widget `WizardPlayerWidget`
- 支持自定义进度条显示（`showProgressBar` 参数）
- 全屏播放支持

```dart
// 使用示例
WizardPlayerWidget(
  player: myPlayer,
  showControls: true,      // 显示控制栏
  showProgressBar: true,   // 显示自定义进度条
  autoPlay: false,         // 不自动播放
  onFullscreen: () => ..., // 全屏回调
)
```

### wizard_player_torrent
BT 种子播放模块，基于 libtorrent，支持种子下载和边下边播。

## 技术栈

- **Flutter** - 跨平台 UI 框架
- **media_kit** - 基于 libmpv 的视频播放解决方案
- **libtorrent** - BT 下载核心库
- **GetX** - 状态管理和依赖注入

## 平台支持

| 平台 | 状态 | 说明 |
|------|------|------|
| Windows | ✅ | 完全支持 |
| Android | ✅ | 完全支持 |
| macOS | ✅ | 完全支持 |
| Linux | ✅ | 完全支持 |
| iOS | ⚠️ | 理论支持，未测试 |

## 注意事项

- `packages` 目录下的模块将在后续分离为独立仓库
- Windows/macOS/Linux 需要安装 libmpv（media_kit 会自动处理）
- Android 需要确保网络权限配置正确

## 许可证

本项目采用 [AGPL-3.0](./LICENSE) 开源协议。

> ⚠️ **重要提示**：根据 AGPL-3.0 协议，如果你使用本项目提供网络服务（如部署为网站或 API），你必须：
> - 公开完整的源代码
> - 包含相同的开源协议
> - 保留版权声明

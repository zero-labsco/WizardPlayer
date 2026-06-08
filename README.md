# Wizard Player

一个支持在线视频和 BT 种子播放的 Flutter 应用。

## 功能特性

- 🎬 在线视频播放
- 🧲 BT 种子/磁链播放（支持边下边播）
- 📺 番剧资源聚合搜索
- ⏯️ 全功能视频播放器
- 📱 移动端 + 桌面端支持

## 快速开始

```bash
# 安装依赖
flutter pub get

# 运行应用
flutter run
```

## 使用说明

### 测试视频
在【发现】页面可以找到测试视频，方便快速测试播放器功能。

### BT 播放
应用会优先使用在线源，当找不到在线源时会自动切换到 BT 源播放。

## Packages 模块说明

### wizard_player_danmaku
弹幕系统，为 WizardPlayer 提供弹幕解析和渲染功能。

### wizard_player_datasource
数据源模块，整合多个视频源，提供统一的数据获取接口。

### wizard_player_media
跨平台视频播放器抽象库，封装 video_player，提供统一的播放器接口。

### wizard_player_torrent
BT 种子播放模块，基于 libtorrent，支持种子下载和边下边播。

## 注意事项

- `packages` 目录下的模块将在后续分离为独立仓库

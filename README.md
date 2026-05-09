# Nbox - 牛盒

基于 Flutter 的全平台影视播放器，完全参考 [FongMi/TV](https://github.com/FongMi/TV) 项目架构设计。

## 功能特性

### 核心功能
- **多源支持**: 支持多个影视数据源切换
- **智能爬虫**: 支持 JS 爬虫脚本，自动解析影视数据
- **视频播放**: 支持 HTTP、HTTPS、M3U8、MP4 等多种格式
- **多线路切换**: 支持多播放源和剧集切换
- **搜索功能**: 支持快速搜索和全文搜索
- **分类浏览**: 支持按分类筛选视频内容

### 高级功能
- **代理支持**: HTTP、HTTPS、SOCKS4、SOCKS5 代理
- **Hosts 映射**: 支持 CDN 加速和域名映射
- **缓存管理**: 智能缓存提高加载速度
- **历史记录**: 自动保存观看历史
- **播放设置**: 倍速播放、画质选择

### 平台支持
| 平台 | 状态 | 说明 |
|------|------|------|
| Android TV | ✅ | 完美支持 |
| Android 手机 | ✅ | 完美支持 |
| iOS | ✅ | 完美支持 |
| Windows | ✅ | 完美支持 |
| macOS | ✅ | 完美支持 |
| Linux | ✅ | 完美支持 |

## 快速开始

### 环境要求

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code
- Android SDK (Android 开发)
- Xcode (iOS 开发)

### 安装依赖

```bash
cd nbox
flutter pub get
```

### 运行应用

```bash
# 运行 Android
flutter run -d android

# 运行 Android TV
flutter run -d android-tv

# 运行 iOS (需要 macOS)
flutter run -d ios

# 运行 Windows
flutter run -d windows

# 运行 macOS (需要 macOS)
flutter run -d macos

# 运行 Linux
flutter run -d linux
```

### 构建发布

```bash
# Android APK (手机版)
flutter build apk --release

# Android TV APK
flutter build apk --release -t lib/main_tv.dart

# iOS
flutter build ios --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## 配置说明

### 添加影视源

编辑 `assets/config/default.json` 文件，添加新的影视源：

```json
{
  "spider": [
    {
      "key": "my_source",
      "name": "我的影视源",
      "api": "https://api.example.com/vod",
      "type": 4,
      "spider": "https://raw.githubusercontent.com/example/spider/main/spider.js",
      "searchable": 1,
      "changeable": 1,
      "quicksearch": 1,
      "filter": 1,
      "enabled": 1
    }
  ]
}
```

### 字段说明

| 字段 | 类型 | 说明 |
|------|------|------|
| key | String | 源唯一标识 |
| name | String | 源显示名称 |
| api | String | API 地址 |
| type | int | 类型 (4 = 点播, 1 = 直播) |
| spider | String | 爬虫 JS 脚本 URL |
| searchable | int | 是否支持搜索 (1 = 是) |
| changeable | int | 是否可换源 (1 = 是) |
| quicksearch | int | 是否快搜 (1 = 是) |
| filter | int | 是否支持筛选 (1 = 是) |
| enabled | int | 是否启用 (1 = 是) |

### 代理配置

```json
{
  "proxy": [
    {
      "name": "自定义代理",
      "hosts": ["googlevideo.com", "youtube.com"],
      "urls": ["socks5://127.0.0.1:7890"]
    }
  ]
}
```

### Hosts 配置

```json
{
  "hosts": [
    {
      "host": "cdn.example.com",
      "rewrite": "base-cdn.example.com"
    }
  ]
}
```

## 技术栈

| 技术 | 用途 |
|------|------|
| Flutter | 跨平台框架 |
| Provider | 状态管理 |
| Dio | HTTP 客户端 |
| video_player | 视频播放 |
| Chewie | 播放器 UI |
| Hive | 本地存储 |
| window_manager | 窗口管理 |

## 常见问题

### Q: 如何添加新的影视源？

A: 编辑 `assets/config/default.json` 文件，按照配置说明添加新的源。

### Q: 播放失败怎么办？

A: 检查以下几点：
1. 确认网络连接正常
2. 检查代理设置是否正确
3. 尝试切换其他播放源
4. 检查视频链接是否过期

## 更新日志

### v1.0.0 (2025-05-09)
- 初始版本发布
- 支持多平台运行
- 实现核心播放功能
- 支持多数据源
- 支持代理和 Hosts

## 许可证

GPL-3.0 License

## 参考项目

- [FongMi/TV](https://github.com/FongMi/TV) - 原始参考项目
- [CatVodTVOfficial/CatVodTVJarLoader](https://github.com/CatVodTVOfficial/CatVodTVJarLoader) - CatVod 核心

# Flutter TV - 全平台影视播放器分析文档

## 项目概述

本项目是基于 Flutter 开发的全平台影视播放器，参考 FongMi/TV 项目架构设计，支持 Android、iOS、Windows、macOS、Linux 等多平台。

## 核心架构

### 1. 模块划分

```
flutter_tv/
├── lib/
│   ├── main.dart                    # 应用入口
│   ├── app.dart                     # 应用主组件
│   ├── core/                        # 核心模块
│   │   ├── models/                  # 数据模型
│   │   │   └── video_source.dart    # 影视源数据模型
│   │   └── services/                # 核心服务
│   │       ├── spider_service.dart   # 爬虫服务
│   │       ├── config_service.dart   # 配置服务
│   │       ├── player_service.dart  # 播放器服务
│   │       ├── proxy_service.dart   # 代理服务
│   │       └── storage_service.dart # 存储服务
│   └── ui/                          # UI 模块
│       ├── pages/                   # 页面
│       │   ├── home_page.dart       # 首页
│       │   └── setting_page.dart    # 设置页
│       ├── widgets/                 # 组件
│       │   ├── video_card.dart      # 视频卡片
│       │   ├── source_selector.dart # 源选择器
│       │   ├── search_bar_widget.dart
│       │   ├── category_tabs.dart
│       │   ├── detail_page.dart     # 详情页
│       │   └── player_page.dart     # 播放器页
│       └── theme/
│           └── app_theme.dart       # 主题配置
├── assets/
│   └── config/
│       └── default.json            # 默认配置
└── pubspec.yaml                    # 项目依赖
```

### 2. 数据模型

#### VideoSource (影视源)
```dart
class VideoSource {
  String? key;           // 源标识
  String? name;          // 源名称
  String? api;           // API 地址
  int? type;            // 类型 (4 = 点播)
  String? spider;        // 爬虫脚本 URL
  int? searchable;       // 是否支持搜索
  int? changeable;       // 是否可换源
  int? quicksearch;      // 是否快搜
  int? filter;           // 是否支持筛选
  int? enabled;          // 是否启用
}
```

#### Video (视频)
```dart
class Video {
  String? vodId;         // 视频 ID
  String? vodName;       // 视频名称
  String? vodPic;        // 海报图
  String? vodRemarks;    // 备注 (如"已完结")
  String? vodYear;       // 年份
  String? vodArea;       // 地区
  String? vodLang;       // 语言
  String? vodType;       // 类型
  String? vodTag;        // 标签
  String? vodDirector;   // 导演
  String? vodActor;      // 主演
  String? vodContent;    // 简介
  String? vodPlayFrom;   // 播放源 (用 $$$ 分隔)
  String? vodPlayUrl;    // 播放URL (用 $$$ 分隔)
}
```

#### Episode (剧集)
```dart
class Episode {
  String? source;        // 源名称
  String? url;           // 播放 URL
}
```

### 3. 服务层

#### SpiderService (爬虫服务)
- **职责**: 管理爬虫脚本加载和执行
- **核心功能**:
  - 加载 JS 爬虫脚本
  - 执行爬虫接口 (homeContent, categoryContent, detailContent, searchContent, playerContent)
  - 缓存爬虫代码

#### ConfigService (配置服务)
- **职责**: 管理应用配置
- **核心功能**:
  - 加载远程/本地配置
  - 管理影视源列表
  - 管理代理规则
  - 管理 Hosts 规则

#### PlayerService (播放器服务)
- **职责**: 视频播放控制
- **核心功能**:
  - 初始化播放器
  - 播放/暂停/seek
  - 倍速播放
  - 全屏控制

#### ProxyService (代理服务)
- **职责**: HTTP/HTTPS/SOCKS 代理
- **支持协议**:
  - HTTP
  - HTTPS
  - SOCKS4
  - SOCKS5

#### StorageService (存储服务)
- **职责**: 本地数据持久化
- **存储内容**:
  - 配置数据
  - 影视源
  - 缓存
  - 观看历史
  - 用户偏好

### 4. 爬虫接口规范

| 接口 | 功能 | 返回 |
|------|------|------|
| homeContent | 首页数据 | `{"class": [], "list": [], "filters": {}}` |
| categoryContent | 分类数据 | `{"page": 1, "pagecount": 1, "list": [], "count": 0}` |
| detailContent | 详情数据 | `{"list": [video]}` |
| searchContent | 搜索结果 | `{"list": []}` |
| playerContent | 播放信息 | `{"parse": 0, "url": ""}` |

### 5. 配置格式 (参考 FongMi/TV)

```json
{
  "spider": [
    {
      "key": "源标识",
      "name": "源名称",
      "api": "https://api.example.com/vod",
      "type": 4,
      "spider": "https://爬虫.js",
      "searchable": 1,
      "changeable": 1,
      "quicksearch": 1,
      "filter": 1,
      "enabled": 1
    }
  ],
  "lives": {
    "type": 1,
    "url": "直播源.txt"
  },
  "config": {
    "ua": "User-Agent",
    "line": {"type": "rect", "ratio": 0.75},
    "wallpaper": "壁纸URL",
    "vipFlag": ["vip.iqiyi.com"]
  },
  "proxy": [],
  "hosts": []
}
```

### 6. 播放器特性

- **协议支持**: HTTP, HTTPS, M3U8, MP4
- **功能特性**:
  - 多种解析模式 (parse=0 直链, parse=1 网页解析)
  - Header 注入
  - 代理支持
  - Hosts 映射
  - 倍速播放
  - 全屏/小屏切换
  - 进度保存

### 7. UI/UX 设计

- **主题**: 暗黑模式为主
- **布局**: 响应式设计
- **组件**:
  - NavigationRail (桌面端侧边栏)
  - GridView (视频列表)
  - Card (卡片组件)
  - BottomSheet (底部弹出)
- **交互**:
  - 遥控器/键盘支持
  - 触摸/鼠标支持

## 技术栈

- **框架**: Flutter 3.16+
- **状态管理**: Provider
- **网络**: Dio
- **视频播放**: video_player + chewie
- **本地存储**: Hive
- **JS 执行**: flutter_js
- **代理**: http_proxy
- **窗口管理**: window_manager

## 平台支持

| 平台 | 状态 | 说明 |
|------|------|------|
| Android | ✅ 完整支持 | TV/手机 |
| iOS | ✅ 完整支持 | TV/手机 |
| Windows | ✅ 完整支持 | 桌面应用 |
| macOS | ✅ 完整支持 | 桌面应用 |
| Linux | ✅ 完整支持 | 桌面应用 |
| Web | ⚠️ 部分支持 | 需要额外适配 |

## 开发指南

### 添加新数据源

1. 在配置中添加新的 VideoSource
2. 提供对应的爬虫 JS 脚本
3. 更新配置 JSON

### 自定义爬虫

爬虫脚本需实现以下接口:
```javascript
class Spider {
  constructor() {}
  
  async homeContent(filter) {}
  async categoryContent(tid, page, filter, extend) {}
  async detailContent(ids) {}
  async searchContent(key, quick, page) {}
  async playerContent(flag, id, vipFlags) {}
}
```

## 注意事项

1. **网络权限**: Android 需要 INTERNET 权限
2. **电视适配**: 默认横屏，遥控器导航
3. **代理规则**: 支持按域名匹配代理
4. **Hosts 映射**: 用于 CDN 加速
5. **缓存策略**: 合理使用缓存提高性能

## 参考项目

- [FongMi/TV](https://github.com/FongMi/TV) - 原始参考项目
- [CatVodTVOfficial/CatVodTVJarLoader](https://github.com/CatVodTVOfficial/CatVodTVJarLoader) - CatVod 核心

## 许可证

GPL-3.0 License

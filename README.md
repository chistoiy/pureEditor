# Pure Edit

一款简洁优雅的纯本地 Android 写作应用，专注于提供纯粹的写作体验。

## 功能特性

### 📝 文档管理
- **文档列表**：支持全部/文件夹/最近三种视图切换
- **文件夹管理**：创建、重命名、删除文件夹
- **文档操作**：新建、重命名、移动、删除文档
- **多选模式**：批量操作文档（移动、删除、分享）
- **搜索功能**：快速搜索文档标题、内容、标签
- **左滑操作**：快速置顶、重命名、删除文档

### ✏️ 编辑功能
- **富文本编辑**：支持加粗、斜体、下划线等格式
- **自动保存**：定时自动保存，防止内容丢失
- **撤销/重做**：支持撤销和重做操作
- **查找替换**：快速查找和替换文本
- **快捷短语**：预设常用短语，一键插入
- **段落格式**：首行缩进、有序列表等
- **字数统计**：准确统计汉字和英文单词数

### 🎨 界面体验
- **深色/浅色主题**：支持跟随系统或手动切换
- **右侧滚动条**：显示阅读进度，支持拖动滚动
- **全面屏适配**：自动适配系统状态栏和手势条
- **自定义边距**：可调整编辑页面的上下左右边距

### ⚙️ 设置中心
- **编辑设置**：自动保存间隔、首行缩进、Markdown模式等
- **外观设置**：主题模式、字体大小、行高、边距设置
- **安全设置**：应用锁、隐私模式、解锁延迟
- **备份设置**：自动备份、备份频率、备份保留数量
- **云同步设置**：WebDAV 配置

### 📅 日记功能
- **日记时间线**：按年月查看日记
- **日记卡片**：显示日期、星期、情绪、字数、标签

### 🗑️ 数据安全
- **回收站**：删除的文档可从回收站恢复
- **历史版本**：查看和恢复历史版本
- **崩溃恢复**：自动备份，防止数据丢失

## 技术栈

- **框架**：Flutter 3.x
- **状态管理**：Provider
- **本地存储**：Hive
- **富文本编辑**：flutter_quill
- **平台**：Android

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   ├── app_settings.dart     # 应用设置
│   └── document.dart         # 文档模型
├── pages/                    # 页面
│   ├── editor_page.dart      # 编辑页面
│   ├── main_page.dart        # 主页面
│   ├── settings_page.dart    # 设置页面
│   ├── splash_page.dart      # 启动页
│   ├── folder_page.dart      # 文件夹页面
│   ├── recycle_bin_page.dart # 回收站页面
│   └── draft_box_page.dart   # 草稿箱页面
├── providers/                # 状态管理
│   ├── document_provider.dart
│   ├── editor_provider.dart
│   └── settings_provider.dart
└── theme/                    # 主题和路由
    ├── app_theme.dart
    └── app_routes.dart
```

## 开始使用

1. 确保已安装 Flutter SDK
2. 克隆项目
```bash
git clone git@github.com:chistoiy/pureEditor.git
cd pureEditor
```
3. 安装依赖
```bash
flutter pub get
```
4. 运行应用
```bash
flutter run
```

## 构建 APK

```bash
flutter build apk --release
```

## 版本历史

### v1.0.0
- 初始版本发布
- 完整的文档管理功能
- 富文本编辑器
- 深色/浅色主题
- 设置中心
- 日记时间线
- 回收站功能

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

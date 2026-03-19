import 'package:flutter/material.dart';
import 'package:pure_editor/theme/app_theme.dart';
import 'package:pure_editor/providers/document_provider.dart';
import 'package:pure_editor/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class FolderPage extends StatelessWidget {
  const FolderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final documentProvider = context.watch<DocumentProvider>();
    final isDark = settingsProvider.isDarkMode;
    final backgroundColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final secondaryColor = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    final folderPath = documentProvider.getFolderPath();
    final documents = documentProvider.documents;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            documentProvider.navigateUp();
            Navigator.pop(context);
          },
        ),
        title: Text(
          folderPath,
          style: TextStyle(color: textColor),
        ),
      ),
      body: documents.isEmpty
          ? Center(
              child: Text(
                '文件夹为空',
                style: TextStyle(color: secondaryColor),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final doc = documents[index];
                return ListTile(
                  title: Text(doc.title.isEmpty ? '未命名文档' : doc.title),
                  subtitle: Text('${doc.wordCount}字'),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/editor',
                      arguments: {'documentId': doc.id},
                    );
                  },
                );
              },
            ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  final String? documentId;
  const HistoryPage({super.key, this.documentId});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = settingsProvider.isDarkMode;
    final backgroundColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('历史版本', style: TextStyle(color: textColor)),
      ),
      body: const Center(
        child: Text('历史版本功能开发中...'),
      ),
    );
  }
}

class TagsPage extends StatelessWidget {
  const TagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = settingsProvider.isDarkMode;
    final backgroundColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('标签管理', style: TextStyle(color: textColor)),
      ),
      body: const Center(
        child: Text('标签管理功能开发中...'),
      ),
    );
  }
}

class TemplatesPage extends StatelessWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = settingsProvider.isDarkMode;
    final backgroundColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('模板管理', style: TextStyle(color: textColor)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTemplateCard(context, '日常日记模板', '日期、天气、情绪、今日事件、复盘反思'),
          _buildTemplateCard(context, '周复盘模板', '周度区间、核心成果、不足改进、下周规划'),
          _buildTemplateCard(context, '月复盘模板', '月度区间、目标完成情况、成长收获'),
          _buildTemplateCard(context, '年度复盘模板', '年度区间、年度目标、核心成就'),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}

class BackupPage extends StatelessWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = settingsProvider.isDarkMode;
    final backgroundColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('备份与恢复', style: TextStyle(color: textColor)),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('立即备份'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('备份成功')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('从备份恢复'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('导入文档'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('导出备份包'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class SyncPage extends StatelessWidget {
  const SyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = settingsProvider.isDarkMode;
    final backgroundColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('云同步设置', style: TextStyle(color: textColor)),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('WebDAV同步'),
            subtitle: const Text('开启后自动同步到云端'),
            value: false,
            onChanged: (_) {},
          ),
          ListTile(
            leading: const Icon(Icons.dns),
            title: const Text('服务器地址'),
            subtitle: const Text('未配置'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('用户名'),
            subtitle: const Text('未配置'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = settingsProvider.isDarkMode;
    final backgroundColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('日记时间线', style: TextStyle(color: textColor)),
      ),
      body: const Center(
        child: Text('日记时间线功能开发中...'),
      ),
    );
  }
}

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = settingsProvider.isDarkMode;
    final backgroundColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('帮助与反馈', style: TextStyle(color: textColor)),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('使用指南'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.question_answer),
            title: const Text('常见问题'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('意见反馈'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = settingsProvider.isDarkMode;
    final backgroundColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('关于Pure Edit', style: TextStyle(color: textColor)),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.edit_note,
                  size: 64,
                  color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Pure Edit',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'v1.0.0',
                  style: TextStyle(color: textColor.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('版本更新'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            title: const Text('开源许可'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            title: const Text('隐私政策'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            title: const Text('用户协议'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pure_editor/pages/splash_page.dart';
import 'package:pure_editor/pages/main_page.dart';
import 'package:pure_editor/pages/editor_page.dart';
import 'package:pure_editor/pages/settings_page.dart';
import 'package:pure_editor/pages/recycle_bin_page.dart';
import 'package:pure_editor/pages/draft_box_page.dart';
import 'package:pure_editor/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:pure_editor/providers/settings_provider.dart';
import 'package:pure_editor/providers/document_provider.dart';
import 'package:intl/intl.dart';

class AppRoutes {
  static const String splash = '/';
  static const String main = '/main';
  static const String editor = '/editor';
  static const String settings = '/settings';
  static const String recycleBin = '/recycle-bin';
  static const String draftBox = '/draft-box';
  static const String folder = '/folder';
  static const String history = '/history';
  static const String tags = '/tags';
  static const String templates = '/templates';
  static const String backup = '/backup';
  static const String sync = '/sync';
  static const String diary = '/diary';
  static const String help = '/help';
  static const String about = '/about';
  static const String settingsEdit = '/settings/edit';
  static const String settingsAppearance = '/settings/appearance';
  static const String settingsBackup = '/settings/backup';
  static const String settingsSync = '/settings/sync';
  static const String settingsSecurity = '/settings/security';
  static const String settingsOther = '/settings/other';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name;

    if (routeName == splash) {
      return MaterialPageRoute(
        builder: (_) => const SplashPage(),
        settings: settings,
      );
    } else if (routeName == main) {
      return MaterialPageRoute(
        builder: (_) => const MainPage(),
        settings: settings,
      );
    } else if (routeName == editor) {
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => EditorPage(documentId: args?['documentId']),
        settings: settings,
      );
    } else if (routeName == AppRoutes.settings) {
      return MaterialPageRoute(
        builder: (_) => const SettingsPage(),
        settings: settings,
      );
    } else if (routeName == recycleBin) {
      return MaterialPageRoute(
        builder: (_) => const RecycleBinPage(),
        settings: settings,
      );
    } else if (routeName == draftBox) {
      return MaterialPageRoute(
        builder: (_) => const DraftBoxPage(),
        settings: settings,
      );
    } else if (routeName == folder) {
      return MaterialPageRoute(
        builder: (_) => const FolderPage(),
        settings: settings,
      );
    } else if (routeName == history) {
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => HistoryPage(documentId: args?['documentId']),
        settings: settings,
      );
    } else if (routeName == tags) {
      return MaterialPageRoute(
        builder: (_) => const TagsPage(),
        settings: settings,
      );
    } else if (routeName == templates) {
      return MaterialPageRoute(
        builder: (_) => const TemplatesPage(),
        settings: settings,
      );
    } else if (routeName == backup) {
      return MaterialPageRoute(
        builder: (_) => const BackupPage(),
        settings: settings,
      );
    } else if (routeName == sync) {
      return MaterialPageRoute(
        builder: (_) => const SyncPage(),
        settings: settings,
      );
    } else if (routeName == diary) {
      return MaterialPageRoute(
        builder: (_) => const DiaryPage(),
        settings: settings,
      );
    } else if (routeName == help) {
      return MaterialPageRoute(
        builder: (_) => const HelpPage(),
        settings: settings,
      );
    } else if (routeName == about) {
      return MaterialPageRoute(
        builder: (_) => const AboutPage(),
        settings: settings,
      );
    } else if (routeName == settingsEdit) {
      return MaterialPageRoute(
        builder: (_) => const EditSettingsPage(),
        settings: settings,
      );
    } else if (routeName == settingsAppearance) {
      return MaterialPageRoute(
        builder: (_) => const AppearanceSettingsPage(),
        settings: settings,
      );
    } else if (routeName == settingsBackup) {
      return MaterialPageRoute(
        builder: (_) => const BackupSettingsPage(),
        settings: settings,
      );
    } else if (routeName == settingsSync) {
      return MaterialPageRoute(
        builder: (_) => const SyncSettingsPage(),
        settings: settings,
      );
    } else if (routeName == settingsSecurity) {
      return MaterialPageRoute(
        builder: (_) => const SecuritySettingsPage(),
        settings: settings,
      );
    } else if (routeName == settingsOther) {
      return MaterialPageRoute(
        builder: (_) => const OtherSettingsPage(),
        settings: settings,
      );
    } else {
      return MaterialPageRoute(builder: (_) => const SplashPage());
    }
  }
}

class FolderPage extends StatelessWidget {
  const FolderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final documentProvider = context.watch<DocumentProvider>();
    final isDark = settingsProvider.isDarkMode;
    final backgroundColor = isDark
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;
    final textColor = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;
    final secondaryColor = isDark
        ? AppTheme.darkTextSecondary
        : AppTheme.lightTextSecondary;

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
        title: Text(folderPath, style: TextStyle(color: textColor)),
      ),
      body: documents.isEmpty
          ? Center(
              child: Text('文件夹为空', style: TextStyle(color: secondaryColor)),
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

class HistoryPage extends StatefulWidget {
  final String? documentId;
  const HistoryPage({super.key, this.documentId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _versions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVersions();
  }

  Future<void> _loadVersions() async {
    // 模拟加载历史版本
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _versions = [
        {
          'id': '1',
          'createdAt': DateTime.now().subtract(const Duration(hours: 1)),
          'wordCount': 1250,
          'type': '自动保存',
        },
        {
          'id': '2',
          'createdAt': DateTime.now().subtract(const Duration(hours: 3)),
          'wordCount': 1180,
          'type': '手动保存',
        },
        {
          'id': '3',
          'createdAt': DateTime.now().subtract(const Duration(days: 1)),
          'wordCount': 1050,
          'type': '自动保存',
        },
        {
          'id': '4',
          'createdAt': DateTime.now().subtract(const Duration(days: 2)),
          'wordCount': 980,
          'type': '自动保存',
        },
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = settingsProvider.isDarkMode;
    final backgroundColor = isDark
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;
    final textColor = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;
    final secondaryColor = isDark
        ? AppTheme.darkTextSecondary
        : AppTheme.lightTextSecondary;

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
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: textColor),
            onPressed: () => _showClearHistoryDialog(),
            tooltip: '清理历史',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
              ),
            )
          : _versions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: secondaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text('暂无历史版本', style: TextStyle(color: secondaryColor)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _versions.length,
              itemBuilder: (context, index) {
                final version = _versions[index];
                return _buildVersionCard(
                  version,
                  textColor,
                  secondaryColor,
                  isDark,
                );
              },
            ),
    );
  }

  Widget _buildVersionCard(
    Map<String, dynamic> version,
    Color textColor,
    Color secondaryColor,
    bool isDark,
  ) {
    final createdAt = version['createdAt'] as DateTime;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.history,
            color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
          ),
        ),
        title: Text(
          dateFormat.format(createdAt),
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
        subtitle: Row(
          children: [
            Text(
              '${version['wordCount']}字',
              style: TextStyle(color: secondaryColor, fontSize: 12),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                version['type'],
                style: TextStyle(
                  color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: secondaryColor),
          onSelected: (value) => _handleVersionAction(value, version),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('查看'),
              ),
            ),
            const PopupMenuItem(
              value: 'restore',
              child: ListTile(leading: Icon(Icons.restore), title: Text('恢复')),
            ),
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.import_export),
                title: Text('导出'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(leading: Icon(Icons.delete), title: Text('删除')),
            ),
          ],
        ),
        onTap: () => _viewVersion(version),
      ),
    );
  }

  void _viewVersion(Map<String, dynamic> version) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('版本内容预览'),
          content: const SizedBox(
            width: double.maxFinite,
            height: 300,
            child: SingleChildScrollView(child: Text('这是历史版本的内容预览...')),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _restoreVersion(version);
              },
              child: const Text('恢复此版本'),
            ),
          ],
        );
      },
    );
  }

  void _handleVersionAction(String action, Map<String, dynamic> version) {
    switch (action) {
      case 'view':
        _viewVersion(version);
        break;
      case 'restore':
        _restoreVersion(version);
        break;
      case 'export':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('导出功能开发中...')));
        break;
      case 'delete':
        _deleteVersion(version);
        break;
    }
  }

  void _restoreVersion(Map<String, dynamic> version) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('恢复版本'),
          content: const Text('确定要恢复到此版本吗？当前内容将被替换。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('已恢复到选定版本')));
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void _deleteVersion(Map<String, dynamic> version) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除版本'),
          content: const Text('确定要删除此历史版本吗？此操作不可撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _versions.remove(version);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('已删除历史版本')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('清理历史版本'),
          content: const Text('确定要清理所有历史版本吗？此操作不可撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _versions.clear();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('已清理所有历史版本')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('清理'),
            ),
          ],
        );
      },
    );
  }
}

class TagsPage extends StatelessWidget {
  const TagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = settingsProvider.isDarkMode;
    final backgroundColor = isDark
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;
    final textColor = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;

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
      body: const Center(child: Text('标签管理功能开发中...')),
    );
  }
}

class TemplatesPage extends StatelessWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = settingsProvider.isDarkMode;
    final backgroundColor = isDark
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;
    final textColor = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;

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

  Widget _buildTemplateCard(
    BuildContext context,
    String title,
    String description,
  ) {
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
    final backgroundColor = isDark
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;
    final textColor = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;

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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('备份成功')));
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
    final backgroundColor = isDark
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;
    final textColor = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;

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

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  String _selectedYear = DateTime.now().year.toString();
  String _selectedMonth = DateTime.now().month.toString();

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = settingsProvider.isDarkMode;
    final backgroundColor = isDark
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;
    final textColor = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;
    final secondaryColor = isDark
        ? AppTheme.darkTextSecondary
        : AppTheme.lightTextSecondary;

    final now = DateTime.now();
    final years = List.generate(5, (i) => (now.year - i).toString());
    final months = List.generate(12, (i) => (i + 1).toString());

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
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: textColor),
            onPressed: () => Navigator.pushNamed(context, '/editor'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedYear,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: years
                        .map(
                          (y) => DropdownMenuItem(value: y, child: Text('$y年')),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedYear = v!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedMonth,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: months
                        .map(
                          (m) => DropdownMenuItem(value: m, child: Text('$m月')),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedMonth = v!),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _getDiaryCount(),
              itemBuilder: (context, index) {
                return _buildDiaryCard(
                  context,
                  index,
                  textColor,
                  secondaryColor,
                  isDark,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getDiaryCount() {
    return 5;
  }

  Widget _buildDiaryCard(
    BuildContext context,
    int index,
    Color textColor,
    Color secondaryColor,
    bool isDark,
  ) {
    final day = index + 1;
    final weekday = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][(day + 5) % 7];
    final mood = ['😀', '😊', '😐', '😔', '😢'][index % 5];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  weekday,
                  style: TextStyle(fontSize: 12, color: secondaryColor),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 80,
            color: secondaryColor.withOpacity(0.3),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(mood, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        '今日日记',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${200 + index * 50}字',
                        style: TextStyle(color: secondaryColor, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '今天发生了很多事情...',
                    style: TextStyle(color: secondaryColor, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.label_outline,
                        size: 14,
                        color: secondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '工作',
                        style: TextStyle(color: secondaryColor, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '#日常',
                        style: TextStyle(color: secondaryColor, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
    final backgroundColor = isDark
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;
    final textColor = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;

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
    final backgroundColor = isDark
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;
    final textColor = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;

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
        ],
      ),
    );
  }
}

class SyncSettingsPage extends StatelessWidget {
  const SyncSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = settingsProvider.isDarkMode;
    final backgroundColor = isDark
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;
    final textColor = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;
    final secondaryColor = isDark
        ? AppTheme.darkTextSecondary
        : AppTheme.lightTextSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '云同步设置',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WebDAV 配置',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: '服务器地址',
                    labelStyle: TextStyle(color: secondaryColor),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: '用户名',
                    labelStyle: TextStyle(color: secondaryColor),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '密码',
                    labelStyle: TextStyle(color: secondaryColor),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('测试连接'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('保存配置'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OtherSettingsPage extends StatelessWidget {
  const OtherSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = settingsProvider.isDarkMode;
    final backgroundColor = isDark
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;
    final textColor = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;
    final secondaryColor = isDark
        ? AppTheme.darkTextSecondary
        : AppTheme.lightTextSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '其他设置',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              title: Text(
                '书写提醒',
                style: TextStyle(color: textColor, fontSize: 16),
              ),
              subtitle: Text(
                '设置每日写作提醒时间',
                style: TextStyle(color: secondaryColor, fontSize: 13),
              ),
              trailing: Icon(Icons.chevron_right, color: secondaryColor),
              onTap: () {},
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              title: Text(
                '关于',
                style: TextStyle(color: textColor, fontSize: 16),
              ),
              subtitle: Text(
                '版本 1.0.0',
                style: TextStyle(color: secondaryColor, fontSize: 13),
              ),
              trailing: Icon(Icons.chevron_right, color: secondaryColor),
              onTap: () => Navigator.pushNamed(context, '/about'),
            ),
          ),
        ],
      ),
    );
  }
}

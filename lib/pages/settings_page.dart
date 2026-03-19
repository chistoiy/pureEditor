import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pure_editor/theme/app_theme.dart';
import 'package:pure_editor/theme/app_routes.dart';
import 'package:pure_editor/providers/settings_provider.dart';
import 'package:pure_editor/models/app_settings.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '设置',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildNavigationTile(
            title: '编辑设置',
            subtitle: '自动保存、首行缩进、Markdown等',
            icon: Icons.edit,
            onTap: () => Navigator.pushNamed(context, '/settings/edit'),
            textColor: textColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
          ),
          _buildNavigationTile(
            title: '外观设置',
            subtitle: '主题模式、字体、边距、全面屏适配',
            icon: Icons.palette,
            onTap: () => Navigator.pushNamed(context, '/settings/appearance'),
            textColor: textColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
          ),
          _buildNavigationTile(
            title: '备份设置',
            subtitle: '自动备份、备份频率、备份保留',
            icon: Icons.backup,
            onTap: () => Navigator.pushNamed(context, '/settings/backup'),
            textColor: textColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
          ),
          _buildNavigationTile(
            title: '云同步设置',
            subtitle: 'WebDAV配置、同步规则',
            icon: Icons.cloud_sync,
            onTap: () => Navigator.pushNamed(context, '/settings/sync'),
            textColor: textColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
          ),
          _buildNavigationTile(
            title: '安全设置',
            subtitle: '应用锁、文档加密、隐私模式',
            icon: Icons.security,
            onTap: () => Navigator.pushNamed(context, '/settings/security'),
            textColor: textColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
          ),
          _buildNavigationTile(
            title: '其他设置',
            subtitle: '书写提醒、关于',
            icon: Icons.more_horiz,
            onTap: () => Navigator.pushNamed(context, '/settings/other'),
            textColor: textColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Color textColor,
    required Color secondaryColor,
    required bool isDark,
  }) {
    final tileColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: secondaryColor, fontSize: 13),
        ),
        trailing: Icon(Icons.chevron_right, color: secondaryColor),
        onTap: onTap,
      ),
    ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.1, end: 0);
  }
}

class EditSettingsPage extends StatefulWidget {
  const EditSettingsPage({super.key});

  @override
  State<EditSettingsPage> createState() => _EditSettingsPageState();
}

class _EditSettingsPageState extends State<EditSettingsPage> {
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
    final settings = settingsProvider.settings;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '编辑设置',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildSliderTile(
            title: '自动保存间隔',
            value: settings.autoSaveInterval.toDouble(),
            min: 1,
            max: 60,
            unit: '秒',
            onChanged: (v) => settingsProvider.setAutoSaveInterval(v.round()),
            textColor: textColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
          ),
          _buildSwitchTile(
            title: '自动首行缩进',
            subtitle: '每段开头自动缩进2字符',
            value: settings.autoFirstLineIndent,
            onChanged: (v) => settingsProvider.setAutoFirstLineIndent(v),
            textColor: textColor,
            isDark: isDark,
          ),
          _buildSwitchTile(
            title: '自动换行',
            subtitle: '关闭后支持横向滚动',
            value: settings.autoWrap,
            onChanged: (v) => settingsProvider.setAutoWrap(v),
            textColor: textColor,
            isDark: isDark,
          ),
          _buildSwitchTile(
            title: '编辑页自动弹出键盘',
            value: settings.autoShowKeyboard,
            onChanged: (v) => settingsProvider.setAutoShowKeyboard(v),
            textColor: textColor,
            isDark: isDark,
          ),
          _buildSwitchTile(
            title: '锁定光标默认开启',
            subtitle: '进入编辑页自动启用锁定光标',
            value: settings.lockCursorDefault,
            onChanged: (v) => settingsProvider.setLockCursorDefault(v),
            textColor: textColor,
            isDark: isDark,
          ),
          _buildSwitchTile(
            title: 'Markdown模式',
            subtitle: '自动识别Markdown语法',
            value: settings.markdownMode,
            onChanged: (v) => settingsProvider.setMarkdownMode(v),
            textColor: textColor,
            isDark: isDark,
          ),
          _buildNavigationTile(
            title: '快捷短语管理',
            subtitle: '添加、编辑、删除快捷短语',
            onTap: () =>
                Navigator.pushNamed(context, '/settings/quick-phrases'),
            textColor: textColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
          ),
          _buildSliderTile(
            title: '光标滑动灵敏度',
            value: settings.cursorSensitivity.toDouble(),
            min: 1,
            max: 5,
            unit: '',
            onChanged: (v) => settingsProvider.setCursorSensitivity(v.round()),
            textColor: textColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textColor,
    required bool isDark,
  }) {
    final tileColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(color: textColor, fontSize: 16)),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              )
            : null,
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
    required Color textColor,
    required Color secondaryColor,
    required bool isDark,
  }) {
    final tileColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: textColor, fontSize: 16)),
              Text(
                '${value.round()}$unit',
                style: TextStyle(color: secondaryColor, fontSize: 14),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required Color textColor,
    required Color secondaryColor,
    required bool isDark,
  }) {
    final tileColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(color: textColor, fontSize: 16)),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(color: secondaryColor, fontSize: 13),
              )
            : null,
        trailing: Icon(Icons.chevron_right, color: secondaryColor),
        onTap: onTap,
      ),
    );
  }
}

class AppearanceSettingsPage extends StatefulWidget {
  const AppearanceSettingsPage({super.key});

  @override
  State<AppearanceSettingsPage> createState() => _AppearanceSettingsPageState();
}

class _AppearanceSettingsPageState extends State<AppearanceSettingsPage> {
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
    final settings = settingsProvider.settings;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '外观设置',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildRadioTile(
            title: '主题模式',
            options: ['跟随系统', '浅色模式', '深色模式'],
            selectedIndex: settings.themeMode.index,
            onChanged: (index) =>
                settingsProvider.setThemeMode(ThemeModeType.values[index]),
            textColor: textColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
          ),
          _buildSliderTile(
            title: '字体大小',
            value: settings.fontSize,
            min: 12,
            max: 24,
            unit: '',
            onChanged: (v) => settingsProvider.setFontSize(v),
            textColor: textColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
          ),
          _buildSliderTile(
            title: '行高',
            value: settings.lineHeight,
            min: 1.0,
            max: 3.0,
            unit: '',
            onChanged: (v) => settingsProvider.setLineHeight(v),
            textColor: textColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
          ),
          _buildSwitchTile(
            title: '全面屏适配',
            subtitle: '自动规避系统状态栏、手势条',
            value: settings.fullScreenAdapt,
            onChanged: (v) => settingsProvider.setFullScreenAdapt(v),
            textColor: textColor,
            isDark: isDark,
          ),
          _buildNavigationTile(
            title: '编辑页边距设置',
            subtitle:
                '上:${settings.topPadding.toInt()} 下:${settings.bottomPadding.toInt()} 左:${settings.leftPadding.toInt()} 右:${settings.rightPadding.toInt()}',
            onTap: () => _showPaddingDialog(settingsProvider),
            textColor: textColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
          ),
          _buildRadioTile(
            title: '屏幕方向锁定',
            options: ['跟随系统', '锁定竖屏', '锁定横屏'],
            selectedIndex: settings.screenOrientation == 'system'
                ? 0
                : (settings.screenOrientation == 'portrait' ? 1 : 2),
            onChanged: (index) {
              final orientations = ['system', 'portrait', 'landscape'];
              settingsProvider.setScreenOrientation(orientations[index]);
            },
            textColor: textColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  void _showPaddingDialog(SettingsProvider provider) {
    double top = provider.settings.topPadding;
    double bottom = provider.settings.bottomPadding;
    double left = provider.settings.leftPadding;
    double right = provider.settings.rightPadding;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('编辑页边距设置'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('顶部: ${top.toInt()}'),
                  Slider(
                    value: top,
                    min: 0,
                    max: 50,
                    divisions: 50,
                    onChanged: (v) => setState(() => top = v),
                  ),
                  Text('底部: ${bottom.toInt()}'),
                  Slider(
                    value: bottom,
                    min: 0,
                    max: 50,
                    divisions: 50,
                    onChanged: (v) => setState(() => bottom = v),
                  ),
                  Text('左边: ${left.toInt()}'),
                  Slider(
                    value: left,
                    min: 0,
                    max: 50,
                    divisions: 50,
                    onChanged: (v) => setState(() => left = v),
                  ),
                  Text('右边: ${right.toInt()}'),
                  Slider(
                    value: right,
                    min: 0,
                    max: 50,
                    divisions: 50,
                    onChanged: (v) => setState(() => right = v),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    provider.updateSettings(
                      provider.settings.copyWith(
                        topPadding: top,
                        bottomPadding: bottom,
                        leftPadding: left,
                        rightPadding: right,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textColor,
    required bool isDark,
  }) {
    final tileColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(color: textColor, fontSize: 16)),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              )
            : null,
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
    required Color textColor,
    required Color secondaryColor,
    required bool isDark,
  }) {
    final tileColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: textColor, fontSize: 16)),
              Text(
                '${value.toStringAsFixed(1)}$unit',
                style: TextStyle(color: secondaryColor, fontSize: 14),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * 10).round(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required Color textColor,
    required Color secondaryColor,
    required bool isDark,
  }) {
    final tileColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(color: textColor, fontSize: 16)),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(color: secondaryColor, fontSize: 13),
              )
            : null,
        trailing: Icon(Icons.chevron_right, color: secondaryColor),
        onTap: onTap,
      ),
    );
  }

  Widget _buildRadioTile({
    required String title,
    required List<String> options,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
    required Color textColor,
    required Color secondaryColor,
    required bool isDark,
  }) {
    final tileColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: textColor, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: options.asMap().entries.map((e) {
              final isSelected = e.key == selectedIndex;
              return ChoiceChip(
                label: Text(e.value),
                selected: isSelected,
                onSelected: (_) => onChanged(e.key),
                selectedColor: isDark
                    ? AppTheme.darkPrimary
                    : AppTheme.lightPrimary,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
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
    final settings = settingsProvider.settings;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '安全设置',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildSwitchTile(
            title: '应用启动锁',
            subtitle: '密码/指纹保护',
            value: settings.appLockEnabled,
            onChanged: (v) => settingsProvider.setAppLockEnabled(v),
            textColor: textColor,
            isDark: isDark,
          ),
          _buildSwitchTile(
            title: '隐私模式',
            subtitle: '禁用截图功能',
            value: settings.privacyMode,
            onChanged: (v) => settingsProvider.setPrivacyMode(v),
            textColor: textColor,
            isDark: isDark,
          ),
          _buildNavigationTile(
            title: '解锁延迟设置',
            subtitle: settings.lockDelay == 0 ? '立即' : '${settings.lockDelay}秒',
            onTap: () => _showLockDelayDialog(settingsProvider),
            textColor: textColor,
            secondaryColor: isDark
                ? AppTheme.darkTextSecondary
                : AppTheme.lightTextSecondary,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  void _showLockDelayDialog(SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('解锁延迟设置'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<int>(
                title: const Text('立即'),
                value: 0,
                groupValue: provider.settings.lockDelay,
                onChanged: (v) {
                  provider.setLockDelay(v!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<int>(
                title: const Text('5秒'),
                value: 5,
                groupValue: provider.settings.lockDelay,
                onChanged: (v) {
                  provider.setLockDelay(v!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<int>(
                title: const Text('30秒'),
                value: 30,
                groupValue: provider.settings.lockDelay,
                onChanged: (v) {
                  provider.setLockDelay(v!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<int>(
                title: const Text('1分钟'),
                value: 60,
                groupValue: provider.settings.lockDelay,
                onChanged: (v) {
                  provider.setLockDelay(v!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textColor,
    required bool isDark,
  }) {
    final tileColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(color: textColor, fontSize: 16)),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              )
            : null,
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }

  Widget _buildNavigationTile({
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required Color textColor,
    required Color secondaryColor,
    required bool isDark,
  }) {
    final tileColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(color: textColor, fontSize: 16)),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(color: secondaryColor, fontSize: 13),
              )
            : null,
        trailing: Icon(Icons.chevron_right, color: secondaryColor),
        onTap: onTap,
      ),
    );
  }
}

class BackupSettingsPage extends StatefulWidget {
  const BackupSettingsPage({super.key});

  @override
  State<BackupSettingsPage> createState() => _BackupSettingsPageState();
}

class _BackupSettingsPageState extends State<BackupSettingsPage> {
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
    final settings = settingsProvider.settings;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '备份设置',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildSwitchTile(
            title: '自动备份',
            subtitle: '定期自动备份所有数据',
            value: settings.autoBackup,
            onChanged: (v) => settingsProvider.setAutoBackup(v),
            textColor: textColor,
            isDark: isDark,
          ),
          _buildNavigationTile(
            title: '备份频率',
            subtitle: '${settings.backupFrequency}小时',
            onTap: () => _showBackupFrequencyDialog(settingsProvider),
            textColor: textColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
          ),
          _buildNavigationTile(
            title: '备份保留数量',
            subtitle: '${settings.backupRetention}份',
            onTap: () => _showBackupRetentionDialog(settingsProvider),
            textColor: textColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
          ),
          _buildNavigationTile(
            title: '回收站保留时长',
            subtitle: '${settings.recycleBinRetention}天',
            onTap: () => _showRecycleBinRetentionDialog(settingsProvider),
            textColor: textColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  void _showBackupFrequencyDialog(SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('备份频率'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [1, 6, 12, 24].map((h) {
              return RadioListTile<int>(
                title: Text('$h小时'),
                value: h,
                groupValue: provider.settings.backupFrequency,
                onChanged: (v) {
                  provider.setBackupFrequency(v!);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showBackupRetentionDialog(SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('备份保留数量'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [7, 15, 30, -1].map((n) {
              return RadioListTile<int>(
                title: Text(n == -1 ? '永久保留' : '$n份'),
                value: n,
                groupValue: provider.settings.backupRetention,
                onChanged: (v) {
                  provider.setBackupRetention(v!);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showRecycleBinRetentionDialog(SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('回收站保留时长'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [7, 30, -1].map((d) {
              return RadioListTile<int>(
                title: Text(d == -1 ? '永久保留' : '$d天'),
                value: d,
                groupValue: provider.settings.recycleBinRetention,
                onChanged: (v) {
                  provider.setRecycleBinRetention(v!);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textColor,
    required bool isDark,
  }) {
    final tileColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(color: textColor, fontSize: 16)),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              )
            : null,
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }

  Widget _buildNavigationTile({
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required Color textColor,
    required Color secondaryColor,
    required bool isDark,
  }) {
    final tileColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(color: textColor, fontSize: 16)),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(color: secondaryColor, fontSize: 13),
              )
            : null,
        trailing: Icon(Icons.chevron_right, color: secondaryColor),
        onTap: onTap,
      ),
    );
  }
}

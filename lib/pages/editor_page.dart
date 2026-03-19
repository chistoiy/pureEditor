import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:pure_editor/theme/app_theme.dart';
import 'package:pure_editor/providers/document_provider.dart';
import 'package:pure_editor/providers/settings_provider.dart';
import 'package:pure_editor/providers/editor_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class EditorPage extends StatefulWidget {
  final String? documentId;

  const EditorPage({super.key, this.documentId});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  Timer? _autoSaveTimer;
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _replaceController = TextEditingController();
  late AnimationController _fabAnimationController;
  bool _isLockCursor = false;
  bool _showQuickPhrases = false;
  double _scrollPercent = 0.0;
  bool _isLocked = false;

  final List<Map<String, String>> _quickPhrases = [
    {'title': '问候语', 'content': '你好，'},
    {
      'title': '日期',
      'content': DateFormat('yyyy年MM月dd日').format(DateTime.now()),
    },
    {'title': '时间', 'content': DateFormat('HH:mm').format(DateTime.now())},
    {
      'title': '日记开头',
      'content': '今天是${DateFormat('yyyy年MM月dd日').format(DateTime.now())}，',
    },
    {'title': '日记结尾', 'content': '\n\n今天就这样了，明天继续加油！'},
    {'title': '分割线', 'content': '\n---\n'},
    {'title': '引用', 'content': '> '},
    {'title': '代码块', 'content': '```\n\n```'},
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scrollController.addListener(_onScroll);
    _focusNode.addListener(_onFocusChange);
    _loadDocument();
    _startAutoSave();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _focusNode.canRequestFocus) {
          _focusNode.requestFocus();
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _autoSaveTimer?.cancel();
    _fabAnimationController.dispose();
    _searchController.dispose();
    _replaceController.dispose();
    _saveBeforeExit();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      if (maxScroll > 0) {
        setState(() {
          _scrollPercent = (currentScroll / maxScroll).clamp(0.0, 1.0);
        });
      }
    }
  }

  void _onFocusChange() {
    setState(() {});
  }

  void _loadDocument() {
    if (widget.documentId != null) {
      final documentProvider = context.read<DocumentProvider>();
      final document = documentProvider.getDocumentById(widget.documentId!);
      if (document != null) {
        context.read<EditorProvider>().loadDocument(document);
        context.read<SettingsProvider>().setLastEditedDocumentId(document.id);

        // 自动弹出键盘
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _focusNode.requestFocus();
          }
        });
      }
    }
  }

  void _startAutoSave() {
    final settings = context.read<SettingsProvider>().settings;
    _autoSaveTimer = Timer.periodic(
      Duration(seconds: settings.autoSaveInterval),
      (_) => _autoSave(),
    );
  }

  Future<void> _autoSave() async {
    final editorProvider = context.read<EditorProvider>();
    if (editorProvider.hasUnsavedChanges) {
      await _saveDocument();
    }
  }

  Future<void> _saveDocument() async {
    final editorProvider = context.read<EditorProvider>();
    final documentProvider = context.read<DocumentProvider>();

    if (editorProvider.currentDocument == null) return;

    await editorProvider.saveDocument();
    await editorProvider.saveToBackup();

    final updatedDocument = editorProvider.currentDocument!.copyWith(
      content: editorProvider.getPlainText(),
      deltaJson: editorProvider.getDeltaJson(),
      wordCount: editorProvider.wordCount,
      updatedAt: DateTime.now(),
    );

    await documentProvider.updateDocument(updatedDocument);
  }

  Future<void> _saveBeforeExit() async {
    final editorProvider = context.read<EditorProvider>();
    if (editorProvider.hasUnsavedChanges) {
      await _saveDocument();
    }
    editorProvider.disposeDocument();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _insertQuickPhrase(String content) {
    final editorProvider = context.read<EditorProvider>();
    editorProvider.insertText(content);
    setState(() => _showQuickPhrases = false);
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final editorProvider = context.watch<EditorProvider>();
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(editorProvider, textColor, secondaryColor, isDark),
              if (_showSearchBar)
                _buildSearchBar(textColor, secondaryColor, isDark),
              if (_showQuickPhrases) _buildQuickPhrasesPanel(textColor, isDark),
              Expanded(
                child: Stack(
                  children: [
                    _buildEditor(
                      editorProvider,
                      settingsProvider,
                      textColor,
                      isDark,
                    ),
                    _buildScrollSlider(secondaryColor, isDark),
                  ],
                ),
              ),
              _buildBottomToolbar(editorProvider, textColor, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPhrasesPanel(Color textColor, bool isDark) {
    return Container(
      height: 200,
      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      child: ListView.builder(
        itemCount: _quickPhrases.length,
        itemBuilder: (context, index) {
          final phrase = _quickPhrases[index];
          return ListTile(
            title: Text(phrase['title']!, style: TextStyle(color: textColor)),
            subtitle: Text(
              phrase['content']!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: textColor.withValues(alpha: 0.6)),
            ),
            onTap: () => _insertQuickPhrase(phrase['content']!),
          );
        },
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildTopBar(
    EditorProvider editorProvider,
    Color textColor,
    Color secondaryColor,
    bool isDark,
  ) {
    final document = editorProvider.currentDocument;
    final isSaving = editorProvider.isSaving;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () async {
              await _saveBeforeExit();
              Navigator.of(context).pop();
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _showRenameDialog(document, textColor),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    document?.title ?? '未命名文档',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isSaving ? '保存中...' : '已保存',
                    style: TextStyle(color: secondaryColor, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showWordStatsDialog(
              editorProvider,
              textColor,
              secondaryColor,
              isDark,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                '${editorProvider.wordCount}字',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: textColor),
            onSelected: (value) => _handleMenuAction(value, editorProvider),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: ListTile(leading: Icon(Icons.share), title: Text('分享')),
              ),
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.import_export),
                  title: Text('导出'),
                ),
              ),
              PopupMenuItem(
                value: 'lock',
                child: ListTile(
                  leading: Icon(_isLocked ? Icons.lock : Icons.lock_open),
                  title: Text(_isLocked ? '解锁编辑' : '锁定编辑'),
                ),
              ),
              const PopupMenuItem(
                value: 'history',
                child: ListTile(
                  leading: Icon(Icons.history),
                  title: Text('历史版本'),
                ),
              ),
              const PopupMenuItem(
                value: 'info',
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('文章属性'),
                ),
              ),
              const PopupMenuItem(
                value: 'rename',
                child: ListTile(leading: Icon(Icons.edit), title: Text('重命名')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Color textColor, Color secondaryColor, bool isDark) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: '查找',
                hintStyle: TextStyle(color: secondaryColor),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) => _performSearch(value),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _replaceController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: '替换',
                hintStyle: TextStyle(color: secondaryColor),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.keyboard_arrow_up, color: textColor),
            onPressed: () =>
                _performSearch(_searchController.text, forward: false),
          ),
          IconButton(
            icon: Icon(Icons.keyboard_arrow_down, color: textColor),
            onPressed: () => _performSearch(_searchController.text),
          ),
          TextButton(
            onPressed: () => _performReplace(),
            child: const Text('替换'),
          ),
          TextButton(
            onPressed: () => _performReplaceAll(),
            child: const Text('全部'),
          ),
          IconButton(
            icon: Icon(Icons.close, color: textColor),
            onPressed: () => setState(() => _showSearchBar = false),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildEditor(
    EditorProvider editorProvider,
    SettingsProvider settingsProvider,
    Color textColor,
    bool isDark,
  ) {
    final settings = settingsProvider.settings;
    final controller = editorProvider.controller;

    if (controller == null) {
      return Center(
        child: CircularProgressIndicator(
          color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 40,
        top: settings.paragraphSpacing,
        bottom: settings.paragraphSpacing,
      ),
      child: QuillEditor(
        controller: controller,
        focusNode: _focusNode,
        scrollController: _scrollController,
      ),
    );
  }

  Widget _buildScrollSlider(Color secondaryColor, bool isDark) {
    return Positioned(
      right: 4,
      top: 0,
      bottom: 0,
      width: 32,
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _scrollToTop,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              child: Text(
                '文顶',
                style: TextStyle(fontSize: 10, color: secondaryColor),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (details) {
                if (_scrollController.hasClients) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final position =
                      (details.localPosition.dy - 32) / (box.size.height - 64);
                  final clampedPosition = position.clamp(0.0, 1.0);
                  final maxScroll = _scrollController.position.maxScrollExtent;
                  _scrollController.jumpTo(clampedPosition * maxScroll);
                }
              },
              child: Container(
                width: 24,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top:
                          _scrollPercent *
                          (MediaQuery.of(context).size.height - 200),
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.darkPrimary
                              : AppTheme.lightPrimary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${(_scrollPercent * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _scrollToBottom,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              child: Text(
                '文底',
                style: TextStyle(fontSize: 10, color: secondaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomToolbar(
    EditorProvider editorProvider,
    Color textColor,
    bool isDark,
  ) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          _buildToolButton(
            icon: _isLockCursor ? Icons.lock : Icons.lock_open,
            label: '锁定',
            onPressed: () => setState(() => _isLockCursor = !_isLockCursor),
            isActive: _isLockCursor,
            textColor: textColor,
            isDark: isDark,
          ),
          _buildToolButton(
            icon: Icons.short_text,
            label: '短语',
            onPressed: () =>
                setState(() => _showQuickPhrases = !_showQuickPhrases),
            textColor: textColor,
            isDark: isDark,
          ),
          _buildToolButton(
            icon: Icons.undo,
            label: '撤销',
            onPressed: () => editorProvider.undo(),
            textColor: textColor,
            isDark: isDark,
          ),
          _buildToolButton(
            icon: Icons.redo,
            label: '重做',
            onPressed: () => editorProvider.redo(),
            textColor: textColor,
            isDark: isDark,
          ),
          _buildToolDivider(isDark),
          _buildToolButton(
            icon: Icons.format_bold,
            label: '加粗',
            onPressed: () => editorProvider.insertBold(),
            textColor: textColor,
            isDark: isDark,
          ),
          _buildToolButton(
            icon: Icons.format_italic,
            label: '斜体',
            onPressed: () => editorProvider.insertItalic(),
            textColor: textColor,
            isDark: isDark,
          ),
          _buildToolButton(
            icon: Icons.format_underlined,
            label: '下划线',
            onPressed: () => editorProvider.insertUnderline(),
            textColor: textColor,
            isDark: isDark,
          ),
          _buildToolDivider(isDark),
          _buildToolButton(
            icon: Icons.format_list_bulleted,
            label: '列表',
            onPressed: () => editorProvider.insertBulletList(),
            textColor: textColor,
            isDark: isDark,
          ),
          _buildToolButton(
            icon: Icons.format_align_left,
            label: '段落',
            onPressed: () =>
                _showParagraphFormatSheet(editorProvider, textColor, isDark),
            textColor: textColor,
            isDark: isDark,
          ),
          _buildToolButton(
            icon: Icons.search,
            label: '查找',
            onPressed: () => setState(() => _showSearchBar = !_showSearchBar),
            textColor: textColor,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color textColor,
    required bool isDark,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive
                  ? (isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary)
                  : textColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive
                    ? (isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary)
                    : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolDivider(bool isDark) {
    return Container(
      height: 32,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      color: isDark
          ? Colors.white.withOpacity(0.1)
          : Colors.black.withOpacity(0.1),
    );
  }

  void _showParagraphFormatSheet(
    EditorProvider editorProvider,
    Color textColor,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.format_indent_increase),
                title: const Text('首行缩进'),
                onTap: () {
                  editorProvider.insertText('\u3000\u3000');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.format_list_numbered),
                title: const Text('有序列表'),
                onTap: () {
                  editorProvider.insertNumberedList();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWordStatsDialog(
    EditorProvider editorProvider,
    Color textColor,
    Color secondaryColor,
    bool isDark,
  ) {
    final document = editorProvider.currentDocument;
    final content = editorProvider.getPlainText();
    final chars = content.length;
    final charsNoSpace = content.replaceAll(RegExp(r'\s'), '').length;
    final chineseChars = content
        .replaceAll(RegExp(r'[^\u4e00-\u9fa5]'), '')
        .length;
    final readingTime = (editorProvider.wordCount / 300).ceil();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('文章详情'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatItem('文档标题', document?.title ?? '未命名文档'),
              _buildStatItem(
                '创建时间',
                DateFormat(
                  'yyyy-MM-dd HH:mm',
                ).format(document?.createdAt ?? DateTime.now()),
              ),
              _buildStatItem(
                '修改时间',
                DateFormat(
                  'yyyy-MM-dd HH:mm',
                ).format(document?.updatedAt ?? DateTime.now()),
              ),
              const Divider(),
              _buildStatItem('总字数', '${editorProvider.wordCount}'),
              _buildStatItem('汉字数', '$chineseChars'),
              _buildStatItem('字符数(含空格)', '$chars'),
              _buildStatItem('字符数(不含空格)', '$charsNoSpace'),
              const Divider(),
              _buildStatItem('预计阅读时长', '$readingTime 分钟'),
              _buildStatItem('累计写作时长', '${document?.writingDuration ?? 0} 分钟'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(dynamic document, Color textColor) {
    final controller = TextEditingController(text: document?.title ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('重命名'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: '请输入文档标题'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                final editorProvider = context.read<EditorProvider>();
                final documentProvider = context.read<DocumentProvider>();
                if (document != null) {
                  final updated = document.copyWith(title: controller.text);
                  await documentProvider.updateDocument(updated);
                  editorProvider.updateDocumentTitle(controller.text);
                }
                Navigator.pop(context);
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void _performSearch(String query, {bool forward = true}) {
    final editorProvider = context.read<EditorProvider>();
    editorProvider.searchText(query);
  }

  void _performReplace() {
    final editorProvider = context.read<EditorProvider>();
    if (_searchController.text.isNotEmpty &&
        _replaceController.text.isNotEmpty) {
      editorProvider.replaceText(
        _searchController.text,
        _replaceController.text,
      );
    }
  }

  void _performReplaceAll() {
    final editorProvider = context.read<EditorProvider>();
    if (_searchController.text.isNotEmpty &&
        _replaceController.text.isNotEmpty) {
      editorProvider.replaceAll(
        _searchController.text,
        _replaceController.text,
      );
    }
  }

  void _handleMenuAction(String value, EditorProvider editorProvider) {
    switch (value) {
      case 'export':
        _exportDocument(editorProvider);
        break;
      case 'history':
        Navigator.pushNamed(
          context,
          '/history',
          arguments: {'documentId': widget.documentId},
        );
        break;
      case 'share':
        _shareDocument(editorProvider);
        break;
      case 'rename':
        _showRenameDialog(
          editorProvider.currentDocument,
          AppTheme.lightTextPrimary,
        );
        break;
      case 'info':
        _showWordStatsDialog(
          editorProvider,
          AppTheme.lightTextPrimary,
          AppTheme.lightTextSecondary,
          false,
        );
        break;
      case 'lock':
        setState(() => _isLocked = !_isLocked);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_isLocked ? '编辑已锁定' : '编辑已解锁')));
        break;
    }
  }

  Future<void> _exportDocument(EditorProvider editorProvider) async {
    final document = editorProvider.currentDocument;
    if (document == null) return;

    try {
      String? path = await FilePicker.platform.saveFile(
        dialogTitle: '导出文档',
        fileName: '${document.title}.txt',
        type: FileType.custom,
        allowedExtensions: ['txt', 'md'],
      );

      if (path != null) {
        final file = File(path);
        await file.writeAsString(editorProvider.getPlainText());
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('已导出到: $path')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('导出失败: $e')));
      }
    }
  }

  void _shareDocument(EditorProvider editorProvider) {
    final content = editorProvider.getPlainText();
    Share.share(
      content,
      subject: editorProvider.currentDocument?.title ?? '分享文档',
    );
  }
}

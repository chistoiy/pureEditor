import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pure_editor/theme/app_theme.dart';
import 'package:pure_editor/providers/document_provider.dart';
import 'package:pure_editor/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  int _currentTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isMultiSelectMode = false;
  Set<String> _selectedIds = {};
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final documentProvider = context.watch<DocumentProvider>();
    final isDark = settingsProvider.isDarkMode;
    final backgroundColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final secondaryColor = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: _buildDrawer(context, settingsProvider, documentProvider, backgroundColor, textColor, secondaryColor, isDark),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, textColor, secondaryColor, isDark),
            _buildTabBar(textColor, secondaryColor, isDark),
            Expanded(
              child: _buildContent(context, documentProvider, textColor, secondaryColor, isDark),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFab(context, documentProvider, backgroundColor, textColor, isDark),
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    SettingsProvider settingsProvider,
    DocumentProvider documentProvider,
    Color backgroundColor,
    Color textColor,
    Color secondaryColor,
    bool isDark,
  ) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: 80,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pure Edit',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(Icons.delete_outline, '文档回收站', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/recycle-bin');
                  }),
                  _buildDrawerItem(Icons.history, '历史版本管理', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/history');
                  }),
                  _buildDrawerItem(Icons.calendar_today, '日记时间线', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/diary');
                  }),
                  _buildDrawerItem(Icons.label_outline, '标签管理', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/tags');
                  }),
                  _buildDrawerItem(Icons.description_outlined, '模板管理', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/templates');
                  }),
                  _buildDrawerItem(Icons.backup, '备份与恢复', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/backup');
                  }),
                  _buildDrawerItem(Icons.cloud_sync, '云同步设置', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/sync');
                  }),
                  _buildDrawerItem(Icons.settings_outlined, '应用设置', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  }),
                  _buildDrawerItem(Icons.help_outline, '帮助与反馈', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/help');
                  }),
                  _buildDrawerItem(Icons.info_outline, '关于Pure Edit', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/about');
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    Color textColor,
    Color secondaryColor,
    bool isDark,
  ) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.menu, color: textColor),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          Expanded(
            child: Text(
              'Pure Edit',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: textColor),
            onPressed: () {
              setState(() => _isSearching = !_isSearching);
            },
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () => _showCreateOptions(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(Color textColor, Color secondaryColor, bool isDark) {
    final tabs = ['全部', '文件夹', '最近'];
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: secondaryColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: tabs.map((tab) {
          final index = tabs.indexOf(tab);
          final isSelected = _currentTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _currentTabIndex = index);
              },
              child: Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tab,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? textColor : secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 24 : 0,
                      height: 3,
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    DocumentProvider documentProvider,
    Color textColor,
    Color secondaryColor,
    bool isDark,
  ) {
    if (_isSearching) {
      return _buildSearchView(context, documentProvider, textColor, secondaryColor, isDark);
    }

    if (_isMultiSelectMode) {
      return _buildMultiSelectView(context, documentProvider, textColor, secondaryColor, isDark);
    }

    final documents = _getDocumentsForTab(documentProvider);
    final folders = _getFoldersForTab(documentProvider);

    if (documents.isEmpty && folders.isEmpty) {
      return _buildEmptyState(textColor, secondaryColor);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: folders.length + documents.length,
      itemBuilder: (context, index) {
        if (index < folders.length) {
          final folder = folders[index];
          return _buildFolderItem(folder, documentProvider, textColor, secondaryColor, isDark);
        } else {
          final doc = documents[index - folders.length];
          return _buildDocumentItem(doc, documentProvider, textColor, secondaryColor, isDark);
        }
      },
    );
  }

  List<dynamic> _getDocumentsForTab(DocumentProvider provider) {
    switch (_currentTabIndex) {
      case 0:
        return provider.documents.where((d) => d.folderId.isEmpty).toList();
      case 1:
        return [];
      case 2:
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        return provider.documents.where((d) => d.updatedAt.isAfter(sevenDaysAgo)).toList();
      default:
        return provider.documents;
    }
  }

  List<dynamic> _getFoldersForTab(DocumentProvider provider) {
    if (_currentTabIndex == 0) {
      return provider.folders;
    } else if (_currentTabIndex == 1) {
      return provider.folders;
    }
    return [];
  }

  Widget _buildEmptyState(Color textColor, Color secondaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: secondaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无文档',
            style: TextStyle(
              fontSize: 16,
              color: textColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角按钮创建新文档',
            style: TextStyle(
              fontSize: 14,
              color: secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderItem(
    dynamic folder,
    DocumentProvider provider,
    Color textColor,
    Color secondaryColor,
    bool isDark,
  ) {
    final docCount = provider.documents.where((d) => d.folderId == folder.id).length;

    return Dismissible(
      key: Key(folder.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        _showDeleteConfirmDialog(folder.name, () {
          provider.deleteFolder(folder.id);
        });
        return false;
      },
      child: ListTile(
        leading: Icon(
          Icons.folder,
          color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
        ),
        title: Text(
          folder.name,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '$docCount 篇文档',
          style: TextStyle(color: secondaryColor, fontSize: 12),
        ),
        trailing: Icon(Icons.chevron_right, color: secondaryColor),
        onTap: () {
          provider.navigateToFolder(folder.id);
          Navigator.pushNamed(context, '/folder');
        },
        onLongPress: () {
          setState(() {
            _isMultiSelectMode = true;
            _selectedIds.add(folder.id);
          });
        },
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildDocumentItem(
    dynamic doc,
    DocumentProvider provider,
    Color textColor,
    Color secondaryColor,
    bool isDark,
  ) {
    final isSelected = _selectedIds.contains(doc.id);
    final dateFormat = DateFormat('MM-dd HH:mm');
    final preview = doc.content.length > 50
        ? '${doc.content.substring(0, 50)}...'
        : doc.content;

    return Dismissible(
      key: Key(doc.id),
      background: Container(
        color: Colors.grey,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          children: [
            Icon(Icons.push_pin, color: Colors.white),
            SizedBox(width: 8),
            Icon(Icons.edit, color: Colors.white),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.white),
            SizedBox(width: 8),
            Icon(Icons.more_horiz, color: Colors.white),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.push_pin, color: Colors.white),
            SizedBox(width: 8),
            Icon(Icons.edit, color: Colors.white),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.white),
            SizedBox(width: 8),
            Icon(Icons.more_horiz, color: Colors.white),
          ],
        ),
      ),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        _showDocOptions(doc, provider);
        return false;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppTheme.darkPrimary.withOpacity(0.2) : AppTheme.lightPrimary.withOpacity(0.1))
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: () {
            if (_isMultiSelectMode) {
              setState(() {
                if (_selectedIds.contains(doc.id)) {
                  _selectedIds.remove(doc.id);
                } else {
                  _selectedIds.add(doc.id);
                }
              });
            } else {
              Navigator.pushNamed(
                context,
                '/editor',
                arguments: {'documentId': doc.id},
              );
            }
          },
          onLongPress: () {
            if (!_isMultiSelectMode) {
              setState(() {
                _isMultiSelectMode = true;
                _selectedIds.add(doc.id);
              });
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      doc.title.isEmpty ? '未命名文档' : doc.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${doc.wordCount}字',
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      preview,
                      style: TextStyle(
                        fontSize: 13,
                        color: secondaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    dateFormat.format(doc.updatedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildSearchView(
    BuildContext context,
    DocumentProvider provider,
    Color textColor,
    Color secondaryColor,
    bool isDark,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '搜索文档标题、内容、标签...',
              hintStyle: TextStyle(color: secondaryColor),
              prefixIcon: Icon(Icons.search, color: secondaryColor),
              suffixIcon: IconButton(
                icon: Icon(Icons.close, color: secondaryColor),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _isSearching = false;
                  });
                },
              ),
              filled: true,
              fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              provider.setSearchQuery(value);
            },
          ),
        ),
        Expanded(
          child: provider.searchResults.isEmpty
              ? Center(
                  child: Text(
                    '未找到匹配的文档',
                    style: TextStyle(color: secondaryColor),
                  ),
                )
              : ListView.builder(
                  itemCount: provider.searchResults.length,
                  itemBuilder: (context, index) {
                    final doc = provider.searchResults[index];
                    return _buildDocumentItem(doc, provider, textColor, secondaryColor, isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectView(
    BuildContext context,
    DocumentProvider provider,
    Color textColor,
    Color secondaryColor,
    bool isDark,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          child: Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    if (_selectedIds.length == provider.documents.length) {
                      _selectedIds.clear();
                    } else {
                      _selectedIds = provider.documents.map((d) => d.id).toSet();
                    }
                  });
                },
                child: Text(
                  _selectedIds.length == provider.documents.length ? '取消全选' : '全选',
                  style: TextStyle(color: textColor),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {
                  final allIds = provider.documents.map((d) => d.id).toSet();
                  setState(() {
                    _selectedIds = allIds.difference(_selectedIds);
                  });
                },
                child: Text(
                  '反选',
                  style: TextStyle(color: textColor),
                ),
              ),
              const Spacer(),
              Text(
                '已选择 ${_selectedIds.length} 项',
                style: TextStyle(color: textColor),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: provider.documents.length,
            itemBuilder: (context, index) {
              final doc = provider.documents[index];
              return CheckboxListTile(
                value: _selectedIds.contains(doc.id),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedIds.add(doc.id);
                    } else {
                      _selectedIds.remove(doc.id);
                    }
                  });
                },
                title: Text(doc.title.isEmpty ? '未命名文档' : doc.title),
                subtitle: Text('${doc.wordCount}字'),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.folder_outlined, color: textColor),
                onPressed: _selectedIds.isNotEmpty
                    ? () => _showMoveDialog(provider)
                    : null,
                tooltip: '移动',
              ),
              IconButton(
                icon: Icon(Icons.share, color: textColor),
                onPressed: _selectedIds.isNotEmpty ? () {} : null,
                tooltip: '分享',
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: _selectedIds.isNotEmpty
                    ? () => _showBatchDeleteDialog(provider)
                    : null,
                tooltip: '删除',
              ),
              IconButton(
                icon: Icon(Icons.close, color: textColor),
                onPressed: () {
                  setState(() {
                    _isMultiSelectMode = false;
                    _selectedIds.clear();
                  });
                },
                tooltip: '退出',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFab(
    BuildContext context,
    DocumentProvider provider,
    Color backgroundColor,
    Color textColor,
    bool isDark,
  ) {
    return FloatingActionButton(
      backgroundColor: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
      child: const Icon(Icons.add, color: Colors.white),
      onPressed: () => _showCreateOptions(context),
    );
  }

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.article),
                title: const Text('新建文章'),
                onTap: () {
                  Navigator.pop(context);
                  _createNewDocument(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('新建文件夹'),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateFolderDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('从模板新建'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/templates');
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_upload),
                title: const Text('从本地文件导入'),
                onTap: () {
                  Navigator.pop(context);
                  _importFromFile(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createNewDocument(BuildContext context) async {
    final provider = context.read<DocumentProvider>();
    final doc = await provider.createDocument();
    if (mounted) {
      Navigator.pushNamed(
        context,
        '/editor',
        arguments: {'documentId': doc.id},
      );
    }
  }

  void _showCreateFolderDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('新建文件夹'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '文件夹名称',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  final provider = context.read<DocumentProvider>();
                  await provider.createFolder(controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('创建'),
            ),
          ],
        );
      },
    );
  }

  void _importFromFile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导入功能开发中...')),
    );
  }

  void _showDocOptions(dynamic doc, DocumentProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.push_pin),
                title: const Text('置顶'),
                onTap: () {
                  Navigator.pop(context);
                  provider.toggleDocumentPinned(doc.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('重命名'),
                onTap: () {
                  Navigator.pop(context);
                  _showRenameDialog(doc, provider);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('删除'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmDialog(doc.title, () {
                    provider.deleteDocument(doc.id);
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.more_horiz),
                title: const Text('更多'),
                onTap: () {
                  Navigator.pop(context);
                  _showMoreOptions(doc, provider);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDialog(dynamic doc, DocumentProvider provider) {
    final controller = TextEditingController(text: doc.title);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('重命名'),
          content: TextField(
            controller: controller,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                await provider.updateDocument(
                  doc.copyWith(title: controller.text),
                );
                Navigator.pop(context);
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(String name, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定将"$name"移入回收站吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: const Text('确定', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showMoreOptions(dynamic doc, DocumentProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: const Text('移动'),
                onTap: () {
                  Navigator.pop(context);
                  _showMoveDocDialog(doc, provider);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('分享'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('加密'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('历史版本'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/history',
                    arguments: {'documentId': doc.id},
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('查看详情'),
                onTap: () {
                  Navigator.pop(context);
                  _showDocDetails(doc);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMoveDocDialog(dynamic doc, DocumentProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('移动到'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: provider.folders.length,
              itemBuilder: (context, index) {
                final folder = provider.folders[index];
                return ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(folder.name),
                  onTap: () async {
                    await provider.moveDocument(doc.id, folder.id);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showDocDetails(dynamic doc) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('文档详情'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('标题: ${doc.title}'),
              const SizedBox(height: 8),
              Text('字数: ${doc.wordCount}'),
              const SizedBox(height: 8),
              Text('创建时间: ${DateFormat('yyyy-MM-dd HH:mm').format(doc.createdAt)}'),
              const SizedBox(height: 8),
              Text('修改时间: ${DateFormat('yyyy-MM-dd HH:mm').format(doc.updatedAt)}'),
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

  void _showMoveDialog(DocumentProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('移动到文件夹'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: provider.folders.length,
              itemBuilder: (context, index) {
                final folder = provider.folders[index];
                return ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(folder.name),
                  onTap: () async {
                    for (final id in _selectedIds) {
                      await provider.moveDocument(id, folder.id);
                    }
                    setState(() {
                      _isMultiSelectMode = false;
                      _selectedIds.clear();
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showBatchDeleteDialog(DocumentProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('批量删除'),
          content: Text('确定删除选中的 ${_selectedIds.length} 个文档吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                for (final id in _selectedIds) {
                  await provider.deleteDocument(id);
                }
                setState(() {
                  _isMultiSelectMode = false;
                  _selectedIds.clear();
                });
                Navigator.pop(context);
              },
              child: const Text('确定', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

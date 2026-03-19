import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pure_editor/theme/app_theme.dart';
import 'package:pure_editor/providers/document_provider.dart';
import 'package:pure_editor/providers/settings_provider.dart';
import 'package:pure_editor/models/document.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DraftBoxPage extends StatefulWidget {
  const DraftBoxPage({super.key});

  @override
  State<DraftBoxPage> createState() => _DraftBoxPageState();
}

class _DraftBoxPageState extends State<DraftBoxPage> {
  List<String> _selectedIds = [];
  bool _isMultiSelectMode = false;

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final documentProvider = context.watch<DocumentProvider>();
    final isDark = settingsProvider.isDarkMode;
    final backgroundColor = isDark ? AppTheme.nightBackground : AppTheme.dayBackground;
    final textColor = isDark ? AppTheme.nightTextPrimary : AppTheme.dayTextPrimary;
    final secondaryColor = isDark ? AppTheme.nightTextSecondary : AppTheme.dayTextSecondary;
    final drafts = documentProvider.drafts;

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
          '草稿箱',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          if (drafts.isNotEmpty)
            TextButton(
              onPressed: () => _showClearAllConfirmDialog(context, documentProvider),
              child: Text('清空', style: TextStyle(color: AppTheme.dayDanger)),
            ),
        ],
      ),
      body: drafts.isEmpty
          ? _buildEmptyState(textColor)
          : _buildDraftList(drafts, documentProvider, textColor, secondaryColor, isDark),
      bottomNavigationBar: _isMultiSelectMode
          ? _buildMultiSelectBar(documentProvider, textColor, isDark)
          : null,
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.drafts,
            size: 80,
            color: textColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '草稿箱为空',
            style: TextStyle(
              fontSize: 18,
              color: textColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '未保存的文档将在这里显示',
            style: TextStyle(
              fontSize: 14,
              color: textColor.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftList(
    List<Document> drafts,
    DocumentProvider documentProvider,
    Color textColor,
    Color secondaryColor,
    bool isDark,
  ) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: drafts.length,
      itemBuilder: (context, index) {
        final document = drafts[index];
        final isSelected = _selectedIds.contains(document.id);

        return GestureDetector(
          onTap: () {
            if (_isMultiSelectMode) {
              _toggleSelection(document.id);
            } else {
              _showDraftOptions(context, documentProvider, document);
            }
          },
          onLongPress: () {
            if (!_isMultiSelectMode) {
              setState(() {
                _isMultiSelectMode = true;
                _selectedIds.add(document.id);
              });
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 4),
            height: 64,
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? AppTheme.nightPrimary.withOpacity(0.2) : AppTheme.dayPrimary.withOpacity(0.1))
                  : cardColor,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: isDark ? AppTheme.nightPrimary : AppTheme.dayPrimary, width: 2)
                  : null,
            ),
            child: ListTile(
              leading: Icon(Icons.drafts, color: secondaryColor),
              title: Text(
                document.title.isEmpty ? '无标题草稿' : document.title,
                style: TextStyle(color: textColor, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${document.wordCount}字 · ${dateFormat.format(document.updatedAt)}',
                style: TextStyle(color: secondaryColor, fontSize: 12),
              ),
              trailing: Icon(Icons.chevron_right, color: secondaryColor),
            ),
          ),
        ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.05, end: 0, duration: 200.ms);
      },
    );
  }

  Widget _buildMultiSelectBar(DocumentProvider documentProvider, Color textColor, bool isDark) {
    final selectedCount = _selectedIds.length;
    final backgroundColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: _selectAll,
            child: Text('全选', style: TextStyle(color: textColor)),
          ),
          const Spacer(),
          Text('$selectedCount 项已选择', style: TextStyle(color: textColor)),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.restore, color: isDark ? AppTheme.nightPrimary : AppTheme.dayPrimary),
            onPressed: selectedCount > 0 ? () => _restoreSelected(documentProvider) : null,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppTheme.dayDanger),
            onPressed: selectedCount > 0 ? () => _deleteSelected(documentProvider) : null,
          ),
          IconButton(
            icon: Icon(Icons.close, color: textColor),
            onPressed: _exitMultiSelectMode,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _isMultiSelectMode = false;
        }
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll() {
    final documentProvider = context.read<DocumentProvider>();
    setState(() {
      _selectedIds = documentProvider.drafts.map((d) => d.id).toList();
    });
  }

  void _exitMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = false;
      _selectedIds.clear();
    });
  }

  void _showDraftOptions(BuildContext context, DocumentProvider provider, Document document) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.restore),
                title: const Text('恢复为正式文档'),
                onTap: () {
                  provider.restoreDraft(document.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('草稿已恢复为正式文档')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.edit, color: AppTheme.dayPrimary),
                title: const Text('继续编辑'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(
                    '/editor',
                    arguments: {'documentId': document.id, 'isDraft': true},
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: AppTheme.dayDanger),
                title: Text('删除', style: TextStyle(color: AppTheme.dayDanger)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmDialog(context, provider, document);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, DocumentProvider provider, Document document) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除草稿'),
          content: Text('确定要删除草稿 "${document.title.isEmpty ? "无标题草稿" : document.title}" 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                provider.deleteDraft(document.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('草稿已删除')),
              );
              },
              child: Text('删除', style: TextStyle(color: AppTheme.dayDanger)),
            ),
          ],
        );
      },
    );
  }

  void _showClearAllConfirmDialog(BuildContext context, DocumentProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('清空草稿箱'),
          content: const Text('确定要清空所有草稿吗？此操作不可撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                provider.clearAllDrafts();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('草稿箱已清空')),
              );
              },
              child: Text('清空', style: TextStyle(color: AppTheme.dayDanger)),
            ),
          ],
        );
      },
    );
  }

  void _restoreSelected(DocumentProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('恢复选中项'),
          content: Text('确定要将 ${_selectedIds.length} 个草稿恢复为正式文档吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                for (final id in _selectedIds) {
                  await provider.restoreDraft(id);
                }
                _exitMultiSelectMode();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('草稿已恢复')),
                );
              },
              child: const Text('恢复'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSelected(DocumentProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除选中项'),
          content: Text('确定要删除 ${_selectedIds.length} 个草稿吗？此操作不可撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                for (final id in _selectedIds) {
                  await provider.deleteDraft(id);
                }
                _exitMultiSelectMode();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('草稿已删除')),
                );
              },
              child: Text('删除', style: TextStyle(color: AppTheme.dayDanger)),
            ),
          ],
        );
      },
    );
  }
}

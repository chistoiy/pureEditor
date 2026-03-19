import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pure_editor/theme/app_theme.dart';
import 'package:pure_editor/providers/document_provider.dart';
import 'package:pure_editor/providers/settings_provider.dart';
import 'package:pure_editor/models/document.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class RecycleBinPage extends StatefulWidget {
  const RecycleBinPage({super.key});

  @override
  State<RecycleBinPage> createState() => _RecycleBinPageState();
}

class _RecycleBinPageState extends State<RecycleBinPage> {
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
    final recycleBin = documentProvider.recycleBin;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('回收站', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w500)),
        actions: [
          if (recycleBin.isNotEmpty)
            TextButton(
              onPressed: () => _showEmptyConfirmDialog(context, documentProvider),
              child: Text('清空', style: TextStyle(color: AppTheme.dayDanger)),
            ),
        ],
      ),
      body: recycleBin.isEmpty
          ? _buildEmptyState(textColor)
          : _buildRecycleBinList(recycleBin, documentProvider, textColor, secondaryColor, isDark),
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
            Icons.delete_outline,
            size: 80,
            color: textColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '回收站为空',
            style: TextStyle(
              fontSize: 18,
              color: textColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '删除的文档将在这里保留30天',
            style: TextStyle(
              fontSize: 14,
              color: textColor.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecycleBinList(
    List<Document> recycleBin,
    DocumentProvider documentProvider,
    Color textColor,
    Color secondaryColor,
    bool isDark,
  ) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: recycleBin.length,
      itemBuilder: (context, index) {
        final document = recycleBin[index];
        final isSelected = _selectedIds.contains(document.id);

        return Dismissible(
          key: Key(document.id),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: AppTheme.dayDanger,
            child: const Icon(Icons.delete_forever, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            _showPermanentDeleteDialog(context, documentProvider, document);
            return false;
          },
          child: GestureDetector(
            onTap: () {
              if (_isMultiSelectMode) {
                _toggleSelection(document.id);
              } else {
                _showDocumentOptions(context, documentProvider, document);
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
                leading: Icon(
                  document.isEncrypted ? Icons.lock : Icons.description,
                  color: secondaryColor,
                ),
                title: Text(
                  document.title,
                  style: TextStyle(color: textColor, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  dateFormat.format(document.updatedAt),
                  style: TextStyle(color: secondaryColor, fontSize: 14),
                ),
              ),
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
            icon: Icon(Icons.delete_forever, color: AppTheme.dayDanger),
            onPressed: selectedCount > 0 ? () => _deleteSelectedPermanently(documentProvider) : null,
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
      _selectedIds = documentProvider.recycleBin.map((d) => d.id).toList();
    });
  }

  void _exitMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = false;
      _selectedIds.clear();
    });
  }

  void _showDocumentOptions(BuildContext context, DocumentProvider provider, Document document) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.restore),
                title: const Text('恢复'),
                onTap: () {
                  provider.restoreFromRecycleBin(document.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('文档已恢复')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_forever, color: AppTheme.dayDanger),
                title: Text('彻底删除', style: TextStyle(color: AppTheme.dayDanger)),
                onTap: () {
                  Navigator.pop(context);
                  _showPermanentDeleteDialog(context, provider, document);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPermanentDeleteDialog(BuildContext context, DocumentProvider provider, Document document) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('彻底删除'),
          content: Text('确定要彻底删除 "${document.title}" 吗？此操作不可撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                provider.permanentlyDelete(document.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('文档已彻底删除')),
                );
              },
              child: Text('删除', style: TextStyle(color: AppTheme.dayDanger)),
            ),
          ],
        );
      },
    );
  }

  void _showEmptyConfirmDialog(BuildContext context, DocumentProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('清空回收站'),
          content: const Text('确定要清空回收站吗？所有文档将被彻底删除，此操作不可撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                provider.emptyRecycleBin();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('回收站已清空')),
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
          content: Text('确定要恢复 ${_selectedIds.length} 个文档吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                for (final id in _selectedIds) {
                  await provider.restoreFromRecycleBin(id);
                }
                _exitMultiSelectMode();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('文档已恢复')),
                );
              },
              child: const Text('恢复'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedPermanently(DocumentProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('彻底删除'),
          content: Text('确定要彻底删除 ${_selectedIds.length} 个文档吗？此操作不可撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                for (final id in _selectedIds) {
                  await provider.permanentlyDelete(id);
                }
                _exitMultiSelectMode();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('文档已彻底删除')),
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

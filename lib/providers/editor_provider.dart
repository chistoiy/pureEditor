import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hive/hive.dart';
import '../models/document.dart' as doc_model;

class EditorProvider extends ChangeNotifier {
  QuillController? _controller;
  doc_model.Document? _currentDocument;
  bool _isSaving = false;
  bool _isDistractionFree = false;
  int _wordCount = 0;
  int _charCount = 0;
  Box<dynamic>? _backupBox;
  String? _lastSavedContent;

  QuillController? get controller => _controller;
  doc_model.Document? get currentDocument => _currentDocument;
  bool get isSaving => _isSaving;
  bool get isDistractionFree => _isDistractionFree;
  int get wordCount => _wordCount;
  int get charCount => _charCount;

  Future<void> init() async {
    _backupBox = await Hive.openBox('document_backup');
  }

  void loadDocument(doc_model.Document document) {
    _controller?.removeListener(_onContentChanged);
    _controller?.dispose();

    _currentDocument = document;

    if (document.deltaJson != null && document.deltaJson!.isNotEmpty) {
      try {
        final List<dynamic> deltaJson = jsonDecode(document.deltaJson!);
        _controller = QuillController(
          document: Document.fromJson(deltaJson),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        _controller = QuillController.basic();
        if (document.content.isNotEmpty) {
          _controller!.document = Document()..insert(0, document.content);
        }
      }
    } else {
      _controller = QuillController.basic();
      if (document.content.isNotEmpty) {
        _controller!.document = Document()..insert(0, document.content);
      }
    }

    _lastSavedContent = _controller!.document.toPlainText();
    _updateWordCount();
    _controller!.addListener(_onContentChanged);
    notifyListeners();
  }

  void _onContentChanged() {
    _updateWordCount();
    notifyListeners();
  }

  void _updateWordCount() {
    if (_controller == null) return;

    final text = _controller!.document.toPlainText();
    _charCount = text.length;

    // 对于中文，统计汉字数量； 对于英文，统计单词数量
    final chineseChars = text
        .replaceAll(RegExp(r'[^\u4e00-\u9fa5]'), '')
        .length;
    final englishWords = text
        .replaceAll(RegExp(r'[\u4e00-\u9fa5]'), ' ')
        .trim()
        .split(RegExp(r'\s+'));

    // 总字数 = 汉字数 + 英文单词数
    _wordCount =
        chineseChars +
        (text.trim().isEmpty
            ? 0
            : englishWords.where((w) => w.isNotEmpty).length);
  }

  Future<void> saveDocument() async {
    if (_controller == null || _currentDocument == null) return;

    _isSaving = true;
    notifyListeners();

    try {
      final content = _controller!.document.toPlainText();
      _lastSavedContent = content;

      await Future.delayed(const Duration(milliseconds: 100));
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> saveToBackup() async {
    if (_controller == null || _currentDocument == null) return;

    final deltaJson = getDeltaJson();
    await _backupBox?.put(_currentDocument!.id, deltaJson);
  }

  String getDeltaJson() {
    if (_controller == null) return '';
    try {
      final delta = _controller!.document.toDelta().toJson();
      return jsonEncode(delta);
    } catch (e) {
      return '';
    }
  }

  Future<void> restoreFromBackup() async {
    if (_currentDocument == null) return;

    final backup = _backupBox?.get(_currentDocument!.id);
    if (backup != null && _controller != null) {
      try {
        final List<dynamic> deltaJson = jsonDecode(backup);
        _controller!.document = Document.fromJson(deltaJson);
        notifyListeners();
      } catch (e) {
        _controller!.document = Document()..insert(0, backup);
        notifyListeners();
      }
    }
  }

  void toggleDistractionFree() {
    _isDistractionFree = !_isDistractionFree;
    notifyListeners();
  }

  void setDistractionFree(bool value) {
    _isDistractionFree = value;
    notifyListeners();
  }

  void undo() {
    _controller?.undo();
  }

  void redo() {
    _controller?.redo();
  }

  void formatText(Attribute attribute) {
    if (_controller == null) return;
    _controller!.formatSelection(attribute);
  }

  void insertBold() {
    formatText(Attribute.bold);
  }

  void insertItalic() {
    formatText(Attribute.italic);
  }

  void insertUnderline() {
    formatText(Attribute.underline);
  }

  void insertStrikethrough() {
    formatText(Attribute.strikeThrough);
  }

  void insertBulletList() {
    formatText(Attribute.ul);
  }

  void insertNumberedList() {
    formatText(Attribute.ol);
  }

  void insertQuote() {
    formatText(Attribute.blockQuote);
  }

  void insertHeading(int level) {
    switch (level) {
      case 1:
        formatText(Attribute.h1);
        break;
      case 2:
        formatText(Attribute.h2);
        break;
      case 3:
        formatText(Attribute.h3);
        break;
      case 4:
        formatText(Attribute.h4);
        break;
      case 5:
        formatText(Attribute.h5);
        break;
      case 6:
        formatText(Attribute.h6);
        break;
      default:
        formatText(Attribute.header);
    }
  }

  void disposeDocument() {
    _controller?.removeListener(_onContentChanged);
    _controller?.dispose();
    _controller = null;
    _currentDocument = null;
    _isDistractionFree = false;
    notifyListeners();
  }

  String getPlainText() {
    return _controller?.document.toPlainText() ?? '';
  }

  String getMarkdown() {
    return _controller?.document.toPlainText() ?? '';
  }

  bool get hasUnsavedChanges {
    if (_controller == null || _lastSavedContent == null) return false;
    return _controller!.document.toPlainText() != _lastSavedContent;
  }

  Future<bool> hasCrashRecovery() async {
    if (_backupBox == null) return false;
    final keys = _backupBox!.keys;
    return keys.isNotEmpty;
  }

  Future<doc_model.Document?> recoverFromCrash() async {
    if (_backupBox == null) return null;

    final keys = _backupBox!.keys.toList();
    if (keys.isEmpty) return null;

    final lastKey = keys.last;
    final backup = _backupBox!.get(lastKey);

    if (backup == null) return null;

    final document = doc_model.Document(
      id: lastKey.toString(),
      title: '恢复的文档',
      content: '',
      deltaJson: backup,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _backupBox!.delete(lastKey);

    return document;
  }

  void insertText(String text) {
    if (_controller == null) return;
    final index = _controller!.selection.baseOffset;
    final length = _controller!.selection.extentOffset - index;
    _controller!.document.replace(index, length, text);
    _controller!.updateSelection(
      TextSelection.collapsed(offset: index + text.length),
      ChangeSource.local,
    );
    _updateWordCount();
    notifyListeners();
  }

  void updateDocumentTitle(String title) {
    if (_currentDocument == null) return;
    _currentDocument = _currentDocument!.copyWith(title: title);
    notifyListeners();
  }

  void searchText(String query) {
    if (_controller == null || query.isEmpty) return;
    final text = _controller!.document.toPlainText();
    final index = text.indexOf(query, _controller!.selection.baseOffset + 1);
    if (index != -1) {
      _controller!.updateSelection(
        TextSelection(baseOffset: index, extentOffset: index + query.length),
        ChangeSource.local,
      );
    }
  }

  void replaceText(String search, String replace) {
    if (_controller == null) return;
    final text = _controller!.document.toPlainText();
    final index = text.indexOf(search, _controller!.selection.baseOffset);
    if (index != -1) {
      _controller!.document.replace(index, search.length, replace);
      _controller!.updateSelection(
        TextSelection.collapsed(offset: index + replace.length),
        ChangeSource.local,
      );
      _updateWordCount();
      notifyListeners();
    }
  }

  void replaceAll(String search, String replace) {
    if (_controller == null) return;
    final text = _controller!.document.toPlainText();
    final newText = text.replaceAll(search, replace);
    _controller!.document = Document()..insert(0, newText);
    _updateWordCount();
    notifyListeners();
  }
}

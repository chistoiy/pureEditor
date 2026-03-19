import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/document.dart';

class Folder {
  final String id;
  final String name;
  final String parentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int sortOrder;

  Folder({
    required this.id,
    required this.name,
    this.parentId = '',
    required this.createdAt,
    required this.updatedAt,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'sortOrder': sortOrder,
    };
  }

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'],
      name: json['name'],
      parentId: json['parentId'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      sortOrder: json['sortOrder'] ?? 0,
    );
  }

  Folder copyWith({
    String? id,
    String? name,
    String? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sortOrder,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class DocumentProvider extends ChangeNotifier {
  List<Document> _documents = [];
  List<Folder> _folders = [];
  List<Document> _recycleBin = [];
  List<Document> _drafts = [];
  String _currentFolderId = '';
  String _searchQuery = '';
  String _sortBy = 'updatedAt';
  bool _sortAscending = false;
  List<String> _selectedIds = [];
  bool _isMultiSelectMode = false;

  Box<dynamic>? _documentBox;
  Box<dynamic>? _folderBox;
  Box<dynamic>? _recycleBox;
  Box<dynamic>? _draftBox;

  List<Document> get documents => _getFilteredDocuments();
  List<Folder> get folders => _getFilteredFolders();
  List<Document> get recycleBin => _recycleBin;
  List<Document> get drafts => _drafts;
  String get currentFolderId => _currentFolderId;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  List<String> get selectedIds => _selectedIds;
  bool get isMultiSelectMode => _isMultiSelectMode;

  List<Document> get searchResults {
    if (_searchQuery.isEmpty) return [];
    final query = _searchQuery.toLowerCase();
    return _documents.where((d) {
      return d.title.toLowerCase().contains(query) ||
          d.content.toLowerCase().contains(query) ||
          d.tags.any((t) => t.toLowerCase().contains(query));
    }).toList();
  }

  Future<void> init() async {
    _documentBox = await Hive.openBox('documents');
    _folderBox = await Hive.openBox('folders');
    _recycleBox = await Hive.openBox('recycle_bin');
    _draftBox = await Hive.openBox('drafts');
    _loadData();
  }

  void _loadData() {
    _documents =
        _documentBox?.values
            .map((e) => Document.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    _folders =
        _folderBox?.values
            .map((e) => Folder.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    _recycleBin =
        _recycleBox?.values
            .map((e) => Document.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    _drafts =
        _draftBox?.values
            .map((e) => Document.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    notifyListeners();
  }

  List<Document> _getFilteredDocuments() {
    var docs = _documents.where((d) => d.folderId == _currentFolderId).toList();

    if (_searchQuery.isNotEmpty) {
      docs = docs.where((d) {
        return d.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            d.content.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    final pinnedDocs = docs.where((d) => d.isPinned).toList();
    final unpinnedDocs = docs.where((d) => !d.isPinned).toList();

    unpinnedDocs.sort((a, b) {
      int result;
      switch (_sortBy) {
        case 'title':
          result = a.title.compareTo(b.title);
          break;
        case 'createdAt':
          result = a.createdAt.compareTo(b.createdAt);
          break;
        case 'updatedAt':
        default:
          result = a.updatedAt.compareTo(b.updatedAt);
      }
      return _sortAscending ? result : -result;
    });

    return [...pinnedDocs, ...unpinnedDocs];
  }

  List<Folder> _getFilteredFolders() {
    return _folders.where((f) => f.parentId == _currentFolderId).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    if (_sortBy == sortBy) {
      _sortAscending = !_sortAscending;
    } else {
      _sortBy = sortBy;
      _sortAscending = false;
    }
    notifyListeners();
  }

  void navigateToFolder(String folderId) {
    _currentFolderId = folderId;
    notifyListeners();
  }

  void navigateUp() {
    if (_currentFolderId.isEmpty) return;
    final currentFolder = _folders.firstWhere(
      (f) => f.id == _currentFolderId,
      orElse: () => Folder(
        id: '',
        name: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    _currentFolderId = currentFolder.parentId;
    notifyListeners();
  }

  Future<Document> createDocument({String title = '', String? folderId}) async {
    final uuid = const Uuid();
    final now = DateTime.now();
    final untitledCount = _documents
        .where((d) => d.title.startsWith('未命名文档'))
        .length;
    final document = Document(
      id: uuid.v4(),
      title: title.isEmpty
          ? '未命名文档${untitledCount > 0 ? '_$untitledCount' : ''}'
          : title,
      content: '',
      createdAt: now,
      updatedAt: now,
      folderId: folderId ?? _currentFolderId,
    );

    _documents.add(document);
    await _documentBox?.put(document.id, document.toJson());
    notifyListeners();
    return document;
  }

  Future<void> updateDocument(Document document) async {
    final index = _documents.indexWhere((d) => d.id == document.id);
    if (index != -1) {
      _documents[index] = document.copyWith(updatedAt: DateTime.now());
      await _documentBox?.put(document.id, _documents[index].toJson());
      notifyListeners();
    }
  }

  Future<void> deleteDocument(
    String documentId, {
    bool permanent = false,
  }) async {
    final document = _documents.firstWhere((d) => d.id == documentId);
    _documents.removeWhere((d) => d.id == documentId);
    await _documentBox?.delete(documentId);

    if (!permanent) {
      _recycleBin.add(document);
      await _recycleBox?.put(documentId, document.toJson());
    }
    notifyListeners();
  }

  Future<void> deleteDocuments(
    List<String> documentIds, {
    bool permanent = false,
  }) async {
    for (final id in documentIds) {
      await deleteDocument(id, permanent: permanent);
    }
  }

  Future<Folder> createFolder(String name, {String? parentId}) async {
    final uuid = const Uuid();
    final now = DateTime.now();
    final folder = Folder(
      id: uuid.v4(),
      name: name,
      parentId: parentId ?? _currentFolderId,
      createdAt: now,
      updatedAt: now,
    );

    _folders.add(folder);
    await _folderBox?.put(folder.id, folder.toJson());
    notifyListeners();
    return folder;
  }

  Future<void> updateFolder(Folder folder) async {
    final index = _folders.indexWhere((f) => f.id == folder.id);
    if (index != -1) {
      _folders[index] = folder.copyWith(updatedAt: DateTime.now());
      await _folderBox?.put(folder.id, _folders[index].toJson());
      notifyListeners();
    }
  }

  Future<void> deleteFolder(String folderId, {bool permanent = false}) async {
    final childDocs = _documents.where((d) => d.folderId == folderId);
    final childFolders = _folders.where((f) => f.parentId == folderId);

    for (final doc in childDocs) {
      await deleteDocument(doc.id, permanent: permanent);
    }

    for (final folder in childFolders) {
      await deleteFolder(folder.id, permanent: permanent);
    }

    _folders.removeWhere((f) => f.id == folderId);
    await _folderBox?.delete(folderId);
    notifyListeners();
  }

  Future<void> moveDocument(String documentId, String targetFolderId) async {
    final index = _documents.indexWhere((d) => d.id == documentId);
    if (index != -1) {
      _documents[index] = _documents[index].copyWith(folderId: targetFolderId);
      await _documentBox?.put(documentId, _documents[index].toJson());
      notifyListeners();
    }
  }

  void toggleMultiSelectMode() {
    _isMultiSelectMode = !_isMultiSelectMode;
    if (!_isMultiSelectMode) {
      _selectedIds.clear();
    }
    notifyListeners();
  }

  void toggleSelection(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedIds = [...documents.map((d) => d.id), ...folders.map((f) => f.id)];
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  Future<void> toggleDocumentPinned(String documentId) async {
    final index = _documents.indexWhere((d) => d.id == documentId);
    if (index != -1) {
      _documents[index] = _documents[index].copyWith(
        isPinned: !_documents[index].isPinned,
      );
      await _documentBox?.put(documentId, _documents[index].toJson());
      notifyListeners();
    }
  }

  Future<void> restoreFromRecycleBin(String documentId) async {
    final document = _recycleBin.firstWhere((d) => d.id == documentId);
    _recycleBin.removeWhere((d) => d.id == documentId);
    _documents.add(document);

    await _recycleBox?.delete(documentId);
    await _documentBox?.put(documentId, document.toJson());
    notifyListeners();
  }

  Future<void> permanentlyDelete(String documentId) async {
    _recycleBin.removeWhere((d) => d.id == documentId);
    await _recycleBox?.delete(documentId);
    notifyListeners();
  }

  Future<void> emptyRecycleBin() async {
    _recycleBin.clear();
    await _recycleBox?.clear();
    notifyListeners();
  }

  String getFolderPath() {
    if (_currentFolderId.isEmpty) return '';

    final path = <String>[];
    String currentId = _currentFolderId;

    while (currentId.isNotEmpty) {
      final folder = _folders.firstWhere(
        (f) => f.id == currentId,
        orElse: () => Folder(
          id: '',
          name: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      if (folder.id.isEmpty) break;
      path.insert(0, folder.name);
      currentId = folder.parentId;
    }

    return path.join(' / ');
  }

  Document? getDocumentById(String id) {
    try {
      return _documents.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  Folder? getFolderById(String id) {
    try {
      return _folders.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveDraft(Document document) async {
    final index = _drafts.indexWhere((d) => d.id == document.id);
    if (index != -1) {
      _drafts[index] = document;
    } else {
      _drafts.add(document);
    }
    await _draftBox?.put(document.id, document.toJson());
    notifyListeners();
  }

  Future<void> restoreDraft(String draftId) async {
    final draft = _drafts.firstWhere((d) => d.id == draftId);
    _drafts.removeWhere((d) => d.id == draftId);
    _documents.add(draft);

    await _draftBox?.delete(draftId);
    await _documentBox?.put(draftId, draft.toJson());
    notifyListeners();
  }

  Future<void> deleteDraft(String draftId) async {
    _drafts.removeWhere((d) => d.id == draftId);
    await _draftBox?.delete(draftId);
    notifyListeners();
  }

  Future<void> clearAllDrafts() async {
    _drafts.clear();
    await _draftBox?.clear();
    notifyListeners();
  }

  Document? getDraftById(String id) {
    try {
      return _drafts.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }
}

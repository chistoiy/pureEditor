import 'package:hive/hive.dart';

class Document extends HiveObject {
  String id;
  String title;
  String content;
  String? deltaJson;
  DateTime createdAt;
  DateTime updatedAt;
  String folderId;
  bool isEncrypted;
  bool isFavorite;
  bool isPinned;
  int wordCount;
  List<String> tags;
  int sortOrder;
  String? summary;
  int writingDuration;

  Document({
    required this.id,
    required this.title,
    this.content = '',
    this.deltaJson,
    required this.createdAt,
    required this.updatedAt,
    this.folderId = '',
    this.isEncrypted = false,
    this.isFavorite = false,
    this.isPinned = false,
    this.wordCount = 0,
    List<String>? tags,
    this.sortOrder = 0,
    this.summary,
    this.writingDuration = 0,
  }) : tags = tags ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'deltaJson': deltaJson,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'folderId': folderId,
      'isEncrypted': isEncrypted,
      'isFavorite': isFavorite,
      'isPinned': isPinned,
      'wordCount': wordCount,
      'tags': tags,
      'sortOrder': sortOrder,
      'summary': summary,
      'writingDuration': writingDuration,
    };
  }

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      title: json['title'],
      content: json['content'] ?? '',
      deltaJson: json['deltaJson'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      folderId: json['folderId'] ?? '',
      isEncrypted: json['isEncrypted'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      isPinned: json['isPinned'] ?? false,
      wordCount: json['wordCount'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      sortOrder: json['sortOrder'] ?? 0,
      summary: json['summary'],
      writingDuration: json['writingDuration'] ?? 0,
    );
  }

  Document copyWith({
    String? id,
    String? title,
    String? content,
    String? deltaJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? folderId,
    bool? isEncrypted,
    bool? isFavorite,
    bool? isPinned,
    int? wordCount,
    List<String>? tags,
    int? sortOrder,
    String? summary,
    int? writingDuration,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      deltaJson: deltaJson ?? this.deltaJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      folderId: folderId ?? this.folderId,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
      wordCount: wordCount ?? this.wordCount,
      tags: tags ?? this.tags,
      sortOrder: sortOrder ?? this.sortOrder,
      summary: summary ?? this.summary,
      writingDuration: writingDuration ?? this.writingDuration,
    );
  }

  bool get isEmpty => content.trim().isEmpty && title.isEmpty;
}

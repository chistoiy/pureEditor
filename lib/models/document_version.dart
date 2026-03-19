import 'package:hive/hive.dart';

class DocumentVersion extends HiveObject {
  String id;
  String documentId;
  String title;
  String content;
  String? deltaJson;
  DateTime createdAt;
  int wordCount;
  String? description;
  bool isLocked;

  DocumentVersion({
    required this.id,
    required this.documentId,
    required this.title,
    required this.content,
    this.deltaJson,
    required this.createdAt,
    required this.wordCount,
    this.description,
    this.isLocked = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'title': title,
      'content': content,
      'deltaJson': deltaJson,
      'createdAt': createdAt.toIso8601String(),
      'wordCount': wordCount,
      'description': description,
      'isLocked': isLocked,
    };
  }

  factory DocumentVersion.fromJson(Map<String, dynamic> json) {
    return DocumentVersion(
      id: json['id'],
      documentId: json['documentId'],
      title: json['title'],
      content: json['content'],
      deltaJson: json['deltaJson'],
      createdAt: DateTime.parse(json['createdAt']),
      wordCount: json['wordCount'],
      description: json['description'],
      isLocked: json['isLocked'] ?? false,
    );
  }

  DocumentVersion copyWith({
    String? id,
    String? documentId,
    String? title,
    String? content,
    String? deltaJson,
    DateTime? createdAt,
    int? wordCount,
    String? description,
    bool? isLocked,
  }) {
    return DocumentVersion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      title: title ?? this.title,
      content: content ?? this.content,
      deltaJson: deltaJson ?? this.deltaJson,
      createdAt: createdAt ?? this.createdAt,
      wordCount: wordCount ?? this.wordCount,
      description: description ?? this.description,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

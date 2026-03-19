import 'package:hive/hive.dart';

class Volume extends HiveObject {
  String id;
  String name;
  DateTime createdAt;
  DateTime updatedAt;
  bool isExpanded;
  int sortOrder;
  String? parentId;

  Volume({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.isExpanded = true,
    this.sortOrder = 0,
    this.parentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isExpanded': isExpanded,
      'sortOrder': sortOrder,
      'parentId': parentId,
    };
  }

  factory Volume.fromJson(Map<String, dynamic> json) {
    return Volume(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isExpanded: json['isExpanded'] ?? true,
      sortOrder: json['sortOrder'] ?? 0,
      parentId: json['parentId'],
    );
  }

  Volume copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isExpanded,
    int? sortOrder,
    String? parentId,
  }) {
    return Volume(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isExpanded: isExpanded ?? this.isExpanded,
      sortOrder: sortOrder ?? this.sortOrder,
      parentId: parentId ?? this.parentId,
    );
  }
}

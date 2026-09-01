import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final int colorValue;
  final int iconCodePoint;
  final int order;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconCodePoint,
    required this.order,
    required this.createdAt,
  });

  static const List<IconData> defaultIcons = [
    Icons.folder_rounded,
    Icons.person_rounded,
    Icons.work_rounded,
    Icons.shopping_cart_rounded,
    Icons.fitness_center_rounded,
    Icons.school_rounded,
    Icons.home_rounded,
    Icons.favorite_rounded,
    Icons.code_rounded,
    Icons.flight_takeoff_rounded,
    Icons.book_rounded,
    Icons.star_rounded,
  ];

  static final Map<int, IconData> _iconMap = {
    for (final icon in defaultIcons) icon.codePoint: icon,
  };

  Color get color => Color(colorValue);
  IconData get icon => _iconMap[iconCodePoint] ?? Icons.folder_rounded;

  Category copyWith({
    String? id,
    String? name,
    int? colorValue,
    int? iconCodePoint,
    int? order,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'iconCodePoint': iconCodePoint,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      colorValue: json['colorValue'] as int? ?? 0xFFF59E0B,
      iconCodePoint: json['iconCodePoint'] as int? ?? 0xe24a, // Icons.folder_rounded
      order: json['order'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

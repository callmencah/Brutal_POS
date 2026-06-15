import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int? id;
  final String nameId;
  final String nameEn;
  final String icon;

  const Category({
    this.id,
    required this.nameId,
    required this.nameEn,
    required this.icon,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      nameId: map['name_id'] as String,
      nameEn: map['name_en'] as String,
      icon: map['icon'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name_id': nameId,
      'name_en': nameEn,
      'icon': icon,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  Category copyWith({
    int? id,
    String? nameId,
    String? nameEn,
    String? icon,
  }) {
    return Category(
      id: id ?? this.id,
      nameId: nameId ?? this.nameId,
      nameEn: nameEn ?? this.nameEn,
      icon: icon ?? this.icon,
    );
  }

  @override
  List<Object?> get props => [id, nameId, nameEn, icon];
}


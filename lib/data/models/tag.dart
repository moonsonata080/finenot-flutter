import 'package:hive/hive.dart';

part 'tag.g.dart';

@HiveType(typeId: 4)
class Tag extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String icon; // Icon name (e.g., 'home', 'car', 'shopping')

  @HiveField(2)
  String color; // Color hex code

  @HiveField(3)
  String category; // Category: personal, business, emergency, etc.

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  bool isDefault; // Is this a default system tag

  Tag({
    required this.name,
    required this.icon,
    required this.color,
    required this.category,
    required this.createdAt,
    this.isDefault = false,
  });

  Tag copyWith({
    String? name,
    String? icon,
    String? color,
    String? category,
    DateTime? createdAt,
    bool? isDefault,
  }) {
    return Tag(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  // Predefined default tags
  static List<Tag> get defaultTags => [
    Tag(
      name: 'Дом',
      icon: 'home',
      color: '#4CAF50',
      category: 'personal',
      createdAt: DateTime.now(),
      isDefault: true,
    ),
    Tag(
      name: 'Авто',
      icon: 'directions_car',
      color: '#2196F3',
      category: 'personal',
      createdAt: DateTime.now(),
      isDefault: true,
    ),
    Tag(
      name: 'Здоровье',
      icon: 'local_hospital',
      color: '#F44336',
      category: 'personal',
      createdAt: DateTime.now(),
      isDefault: true,
    ),
    Tag(
      name: 'Образование',
      icon: 'school',
      color: '#9C27B0',
      category: 'personal',
      createdAt: DateTime.now(),
      isDefault: true,
    ),
    Tag(
      name: 'Бизнес',
      icon: 'business',
      color: '#FF9800',
      category: 'business',
      createdAt: DateTime.now(),
      isDefault: true,
    ),
    Tag(
      name: 'Срочно',
      icon: 'priority_high',
      color: '#E91E63',
      category: 'emergency',
      createdAt: DateTime.now(),
      isDefault: true,
    ),
    Tag(
      name: 'Развлечения',
      icon: 'entertainment',
      color: '#00BCD4',
      category: 'personal',
      createdAt: DateTime.now(),
      isDefault: true,
    ),
    Tag(
      name: 'Налоги',
      icon: 'receipt',
      color: '#795548',
      category: 'government',
      createdAt: DateTime.now(),
      isDefault: true,
    ),
  ];
}

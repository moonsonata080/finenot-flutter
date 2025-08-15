import 'package:hive/hive.dart';

part 'org.g.dart';

@HiveType(typeId: 3)
class Org extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String type; // bank, mfo

  @HiveField(2)
  String? bic;

  @HiveField(3)
  String? ogrn;

  @HiveField(4)
  String? brand;

  @HiveField(5)
  String searchIndex; // Normalized string for fast search

  Org({
    required this.name,
    required this.type,
    this.bic,
    this.ogrn,
    this.brand,
    required this.searchIndex,
  });

  Org copyWith({
    String? name,
    String? type,
    String? bic,
    String? ogrn,
    String? brand,
    String? searchIndex,
  }) {
    return Org(
      name: name ?? this.name,
      type: type ?? this.type,
      bic: bic ?? this.bic,
      ogrn: ogrn ?? this.ogrn,
      brand: brand ?? this.brand,
      searchIndex: searchIndex ?? this.searchIndex,
    );
  }

  // Helper method to get display name
  String get displayName => brand ?? name;
}

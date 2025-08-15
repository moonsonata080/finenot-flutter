import 'package:hive/hive.dart';

part 'payment.g.dart';

@HiveType(typeId: 1)
class Payment extends HiveObject {
  @HiveField(0)
  int creditId; // Reference to credit

  @HiveField(1)
  double amount;

  @HiveField(2)
  DateTime dueDate;

  @HiveField(3)
  DateTime? paidDate;

  @HiveField(4)
  String status; // pending, paid, missed, partial

  @HiveField(5)
  DateTime createdAt;

  Payment({
    required this.creditId,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    required this.createdAt,
  });

  Payment copyWith({
    int? creditId,
    double? amount,
    DateTime? dueDate,
    DateTime? paidDate,
    String? status,
    DateTime? createdAt,
  }) {
    return Payment(
      creditId: creditId ?? this.creditId,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

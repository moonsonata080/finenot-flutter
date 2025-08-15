import 'package:isar/isar.dart';
import 'credit.dart';

part 'payment.g.dart';

@collection
class Payment {
  Id id = Isar.autoIncrement;

  double amount;

  DateTime dueDate;

  DateTime? paidDate;

  @enumerated
  PaymentStatus status = PaymentStatus.pending;

  @enumerated
  PaymentType type = PaymentType.regular;

  DateTime createdAt = DateTime.now();

  final IsarLink<Credit> credit = IsarLink<Credit>();

  Payment({
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    required this.type,
  });

  // JSON serialization for backup/restore
  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'dueDate': dueDate.toIso8601String(),
        'paidDate': paidDate?.toIso8601String(),
        'status': status.name,
        'type': type.name,
        'createdAt': createdAt.toIso8601String(),
        'creditId': credit.value?.id,
      };

  factory Payment.fromJson(Map<String, dynamic> json) {
    final payment = Payment(
      amount: (json['amount'] ?? 0).toDouble(),
      dueDate: DateTime.parse(json['dueDate']),
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate']) : null,
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      type: PaymentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PaymentType.regular,
      ),
    );
    
    if (json['createdAt'] != null) {
      payment.createdAt = DateTime.parse(json['createdAt']);
    }
    
    return payment;
  }
}

enum PaymentStatus {
  pending,
  paid,
  missed,
  partial,
}

enum PaymentType {
  regular,
  partial,
  custom,
}

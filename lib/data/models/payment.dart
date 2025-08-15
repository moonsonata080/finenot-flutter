// Simple Payment model without Isar for testing
class Payment {
  int id;
  double amount;
  DateTime dueDate;
  DateTime? paidDate;
  PaymentStatus status;
  PaymentType type;
  DateTime createdAt;
  int creditId;

  Payment({
    required this.id,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    required this.type,
    required this.createdAt,
    required this.creditId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'status': status.name,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'creditId': creditId,
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      amount: json['amount'].toDouble(),
      dueDate: DateTime.parse(json['dueDate']),
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate']) : null,
      status: PaymentStatus.values.firstWhere((e) => e.name == json['status']),
      type: PaymentType.values.firstWhere((e) => e.name == json['type']),
      createdAt: DateTime.parse(json['createdAt']),
      creditId: json['creditId'],
    );
  }
}

enum PaymentStatus {
  pending,
  paid,
  partial,
  overdue,
}

enum PaymentType {
  regular,
  partial,
  extra,
}

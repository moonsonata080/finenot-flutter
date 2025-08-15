// Simple Credit model without Isar for testing
class Credit {
  int id;
  String name;
  String? bankName;
  DateTime createdAt;
  double initialAmount;
  double currentBalance;
  double monthlyPayment;
  double interestRate;
  DateTime nextPaymentDate;
  CreditStatus status;
  CreditType type;

  Credit({
    required this.id,
    required this.name,
    this.bankName,
    required this.createdAt,
    required this.initialAmount,
    required this.currentBalance,
    required this.monthlyPayment,
    required this.interestRate,
    required this.nextPaymentDate,
    required this.status,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bankName': bankName,
      'createdAt': createdAt.toIso8601String(),
      'initialAmount': initialAmount,
      'currentBalance': currentBalance,
      'monthlyPayment': monthlyPayment,
      'interestRate': interestRate,
      'nextPaymentDate': nextPaymentDate.toIso8601String(),
      'status': status.name,
      'type': type.name,
    };
  }

  factory Credit.fromJson(Map<String, dynamic> json) {
    return Credit(
      id: json['id'],
      name: json['name'],
      bankName: json['bankName'],
      createdAt: DateTime.parse(json['createdAt']),
      initialAmount: json['initialAmount'].toDouble(),
      currentBalance: json['currentBalance'].toDouble(),
      monthlyPayment: json['monthlyPayment'].toDouble(),
      interestRate: json['interestRate'].toDouble(),
      nextPaymentDate: DateTime.parse(json['nextPaymentDate']),
      status: CreditStatus.values.firstWhere((e) => e.name == json['status']),
      type: CreditType.values.firstWhere((e) => e.name == json['type']),
    );
  }
}

enum CreditStatus {
  active,
  paid,
  overdue,
  defaulted,
}

enum CreditType {
  consumer,
  mortgage,
  microloan,
}

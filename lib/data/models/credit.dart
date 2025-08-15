import 'package:isar/isar.dart';
import 'payment.dart';

part 'credit.g.dart';

@collection
class Credit {
  Id id = Isar.autoIncrement;

  String name;

  String? bankName;

  @enumerated
  CreditType type = CreditType.consumer;

  double initialAmount;

  double currentBalance;

  double monthlyPayment;

  double interestRate;

  DateTime nextPaymentDate;

  @enumerated
  CreditStatus status = CreditStatus.active;

  DateTime createdAt = DateTime.now();

  @Backlink(to: 'credit')
  final IsarLinks<Payment> payments = IsarLinks<Payment>();

  Credit({
    required this.name,
    this.bankName,
    required this.type,
    required this.initialAmount,
    required this.currentBalance,
    required this.monthlyPayment,
    required this.interestRate,
    required this.nextPaymentDate,
    required this.status,
  });

  // JSON serialization for backup/restore
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bankName': bankName,
        'type': type.name,
        'initialAmount': initialAmount,
        'currentBalance': currentBalance,
        'monthlyPayment': monthlyPayment,
        'interestRate': interestRate,
        'nextPaymentDate': nextPaymentDate.toIso8601String(),
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Credit.fromJson(Map<String, dynamic> json) {
    final credit = Credit(
      name: json['name'] ?? '',
      bankName: json['bankName'],
      type: CreditType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CreditType.consumer,
      ),
      initialAmount: (json['initialAmount'] ?? 0).toDouble(),
      currentBalance: (json['currentBalance'] ?? 0).toDouble(),
      monthlyPayment: (json['monthlyPayment'] ?? 0).toDouble(),
      interestRate: (json['interestRate'] ?? 0).toDouble(),
      nextPaymentDate: DateTime.parse(json['nextPaymentDate']),
      status: CreditStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CreditStatus.active,
      ),
    );
    
    if (json['createdAt'] != null) {
      credit.createdAt = DateTime.parse(json['createdAt']);
    }
    
    return credit;
  }
}

enum CreditType {
  consumer,
  mortgage,
  micro,
}

enum CreditStatus {
  active,
  closed,
  overdue,
}

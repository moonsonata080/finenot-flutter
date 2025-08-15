import 'package:hive/hive.dart';

part 'credit.g.dart';

@HiveType(typeId: 0)
class Credit extends HiveObject {
  @HiveField(0)
  String? orgId; // Reference to bank/MFO

  @HiveField(1)
  String name;

  @HiveField(2)
  String type; // consumer, mortgage, micro, card

  @HiveField(3)
  double initialAmount;

  @HiveField(4)
  double currentBalance;

  @HiveField(5)
  double monthlyPayment;

  @HiveField(6)
  double interestRate;

  @HiveField(7)
  DateTime nextPaymentDate;

  @HiveField(8)
  String status; // active, closed, overdue

  @HiveField(9)
  DateTime createdAt;

  Credit({
    this.orgId,
    required this.name,
    required this.type,
    required this.initialAmount,
    required this.currentBalance,
    required this.monthlyPayment,
    required this.interestRate,
    required this.nextPaymentDate,
    required this.status,
    required this.createdAt,
  });

  Credit copyWith({
    String? orgId,
    String? name,
    String? type,
    double? initialAmount,
    double? currentBalance,
    double? monthlyPayment,
    double? interestRate,
    DateTime? nextPaymentDate,
    String? status,
    DateTime? createdAt,
  }) {
    return Credit(
      orgId: orgId ?? this.orgId,
      name: name ?? this.name,
      type: type ?? this.type,
      initialAmount: initialAmount ?? this.initialAmount,
      currentBalance: currentBalance ?? this.currentBalance,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      interestRate: interestRate ?? this.interestRate,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

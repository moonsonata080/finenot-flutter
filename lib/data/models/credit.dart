import 'package:hive/hive.dart';

part 'credit.g.dart';

@HiveType(typeId: 0)
class Credit extends HiveObject {
  @HiveField(0)
  String? orgId; // Reference to bank/MFO

  @HiveField(1)
  String name;

  @HiveField(2)
  String type; // consumer, mortgage, micro, card, installment, fine, tax, alimony, rent

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

  @HiveField(10)
  List<String> tags; // Tags for categorization

  @HiveField(11)
  String? description; // Additional description

  @HiveField(12)
  String paymentFrequency; // monthly, weekly, quarterly, yearly, custom

  @HiveField(13)
  int? customDays; // For custom frequency (e.g., every 14 days)

  @HiveField(14)
  DateTime? endDate; // End date for the obligation

  @HiveField(15)
  double? penaltyRate; // Penalty rate for overdue payments

  @HiveField(16)
  bool isRecurring; // Is this a recurring obligation

  @HiveField(17)
  String? contractNumber; // Contract or account number

  @HiveField(18)
  String? contactInfo; // Contact information for the creditor

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
    this.tags = const [],
    this.description,
    this.paymentFrequency = 'monthly',
    this.customDays,
    this.endDate,
    this.penaltyRate,
    this.isRecurring = true,
    this.contractNumber,
    this.contactInfo,
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
    List<String>? tags,
    String? description,
    String? paymentFrequency,
    int? customDays,
    DateTime? endDate,
    double? penaltyRate,
    bool? isRecurring,
    String? contractNumber,
    String? contactInfo,
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
      tags: tags ?? this.tags,
      description: description ?? this.description,
      paymentFrequency: paymentFrequency ?? this.paymentFrequency,
      customDays: customDays ?? this.customDays,
      endDate: endDate ?? this.endDate,
      penaltyRate: penaltyRate ?? this.penaltyRate,
      isRecurring: isRecurring ?? this.isRecurring,
      contractNumber: contractNumber ?? this.contractNumber,
      contactInfo: contactInfo ?? this.contactInfo,
    );
  }
}

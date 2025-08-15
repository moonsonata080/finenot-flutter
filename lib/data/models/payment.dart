import 'package:hive/hive.dart';

part 'payment.g.dart';

@HiveType(typeId: 1)
class Payment extends HiveObject {
  @HiveField(0)
  String creditId; // Reference to credit

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

  @HiveField(6)
  double? paidAmount; // Actual amount paid (for partial payments)

  @HiveField(7)
  String? notes; // Additional notes about the payment

  @HiveField(8)
  List<String> tags; // Tags for categorization

  @HiveField(9)
  String? receiptNumber; // Receipt or confirmation number

  @HiveField(10)
  String? paymentMethod; // cash, card, transfer, etc.

  @HiveField(11)
  bool isRecurring; // Is this a recurring payment

  @HiveField(12)
  int? reminderHours; // Hours before due date to send reminder

  @HiveField(13)
  bool reminderSent; // Whether reminder was sent for this payment

  Payment({
    required this.creditId,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    required this.createdAt,
    this.paidAmount,
    this.notes,
    this.tags = const [],
    this.receiptNumber,
    this.paymentMethod,
    this.isRecurring = true,
    this.reminderHours,
    this.reminderSent = false,
  });

  Payment copyWith({
    String? creditId,
    double? amount,
    DateTime? dueDate,
    DateTime? paidDate,
    String? status,
    DateTime? createdAt,
    double? paidAmount,
    String? notes,
    List<String>? tags,
    String? receiptNumber,
    String? paymentMethod,
    bool? isRecurring,
    int? reminderHours,
    bool? reminderSent,
  }) {
    return Payment(
      creditId: creditId ?? this.creditId,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      paidAmount: paidAmount ?? this.paidAmount,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isRecurring: isRecurring ?? this.isRecurring,
      reminderHours: reminderHours ?? this.reminderHours,
      reminderSent: reminderSent ?? this.reminderSent,
    );
  }
}

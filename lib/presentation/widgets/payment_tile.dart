import 'package:flutter/material.dart';
import '../../data/models/payment.dart';

class PaymentTile extends StatelessWidget {
  final Payment payment;
  final VoidCallback? onTap;

  const PaymentTile({
    super.key,
    required this.payment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = payment.status == 'pending' && payment.dueDate.isBefore(DateTime.now());
    final daysUntilPayment = payment.dueDate.difference(DateTime.now()).inDays;
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with amount and status
              Row(
                children: [
                  // Amount
                  Expanded(
                    child: Text(
                      '${payment.amount.toStringAsFixed(0)} ₽',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getPaymentStatusColor(payment.status),
                      ),
                    ),
                  ),
                  
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getPaymentStatusColor(payment.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getPaymentStatusIcon(payment.status),
                          size: 16,
                          color: _getPaymentStatusColor(payment.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getPaymentStatusDisplayName(payment.status),
                          style: TextStyle(
                            color: _getPaymentStatusColor(payment.status),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Payment details
              Row(
                children: [
                  // Due date
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      Icons.calendar_today,
                      'Дата платежа',
                      '${payment.dueDate.day}.${payment.dueDate.month}.${payment.dueDate.year}',
                      isOverdue ? Colors.red : null,
                    ),
                  ),
                  
                  // Days until payment
                  if (payment.status == 'pending') ...[
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getUrgencyColor(daysUntilPayment).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getUrgencyText(daysUntilPayment),
                        style: TextStyle(
                          color: _getUrgencyColor(daysUntilPayment),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              
              // Paid date (if paid)
              if (payment.paidDate != null) ...[
                const SizedBox(height: 8),
                _buildDetailItem(
                  context,
                  Icons.check_circle,
                  'Дата оплаты',
                  '${payment.paidDate!.day}.${payment.paidDate!.month}.${payment.paidDate!.year}',
                  Colors.green,
                ),
              ],
              
              // Progress indicator for overdue payments
              if (isOverdue) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        size: 16,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Просрочен на ${daysUntilPayment.abs()} дн.',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color? color,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'partial':
        return Colors.blue;
      case 'missed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'paid':
        return Icons.check_circle;
      case 'partial':
        return Icons.pending;
      case 'missed':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  String _getPaymentStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'Ожидает';
      case 'paid':
        return 'Оплачен';
      case 'partial':
        return 'Частично';
      case 'missed':
        return 'Пропущен';
      default:
        return status;
    }
  }

  Color _getUrgencyColor(int days) {
    if (days < 0) return Colors.red;
    if (days <= 3) return Colors.red;
    if (days <= 7) return Colors.orange;
    return Colors.green;
  }

  String _getUrgencyText(int days) {
    if (days < 0) return 'Просрочен';
    if (days == 0) return 'Сегодня';
    if (days == 1) return 'Завтра';
    if (days <= 7) return 'Через $days дн.';
    return 'Через $days дн.';
  }
}

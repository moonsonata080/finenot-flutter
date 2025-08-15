import 'package:flutter/material.dart';
import '../../data/models/credit.dart';

class CreditCard extends StatelessWidget {
  final Credit credit;
  final VoidCallback? onTap;

  const CreditCard({
    super.key,
    required this.credit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = credit.currentBalance / credit.initialAmount;
    final remainingAmount = credit.initialAmount - credit.currentBalance;
    
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
              // Header
              Row(
                children: [
                  // Credit type icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getCreditTypeColor(credit.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCreditTypeIcon(credit.type),
                      color: _getCreditTypeColor(credit.type),
                      size: 20,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Credit info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          credit.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _getCreditTypeDisplayName(credit.type),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(credit.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusDisplayName(credit.status),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(credit.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Amounts
              Row(
                children: [
                  Expanded(
                    child: _buildAmountInfo(
                      context,
                      'Остаток',
                      '${credit.currentBalance.toStringAsFixed(0)} ₽',
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAmountInfo(
                      context,
                      'Ежемесячный платеж',
                      '${credit.monthlyPayment.toStringAsFixed(0)} ₽',
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Прогресс погашения',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getCreditTypeColor(credit.type),
                    ),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Погашено: ${remainingAmount.toStringAsFixed(0)} ₽',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Additional info
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      'Ставка',
                      '${credit.interestRate.toStringAsFixed(1)}%',
                      Icons.percent,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      'Следующий платеж',
                      '${credit.nextPaymentDate.day}.${credit.nextPaymentDate.month}',
                      Icons.calendar_today,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInfo(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCreditTypeColor(String type) {
    switch (type) {
      case 'consumer':
        return Colors.blue;
      case 'mortgage':
        return Colors.green;
      case 'micro':
        return Colors.orange;
      case 'card':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCreditTypeIcon(String type) {
    switch (type) {
      case 'consumer':
        return Icons.person;
      case 'mortgage':
        return Icons.home;
      case 'micro':
        return Icons.account_balance;
      case 'card':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }

  String _getCreditTypeDisplayName(String type) {
    switch (type) {
      case 'consumer':
        return 'Потребительский';
      case 'mortgage':
        return 'Ипотека';
      case 'micro':
        return 'Микрокредит';
      case 'card':
        return 'Кредитная карта';
      default:
        return type;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'active':
        return 'Активный';
      case 'closed':
        return 'Закрыт';
      case 'overdue':
        return 'Просрочен';
      default:
        return status;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/credit.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';

class CreditCard extends StatelessWidget {
  final Credit credit;

  const CreditCard({super.key, required this.credit});

  @override
  Widget build(BuildContext context) {
    final progress = credit.currentBalance / credit.initialAmount;
    final remainingDebt = credit.initialAmount - credit.currentBalance;
    final overpayment = credit.currentBalance - remainingDebt;

    return Card(
      child: InkWell(
        onTap: () => _showCreditDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и статус
              Row(
                children: [
                  Expanded(
                    child: Text(
                      credit.name,
                      style: AppTextStyles.heading2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              const SizedBox(height: 8),
              
              // Банк и тип кредита
              Row(
                children: [
                  Icon(
                    Icons.account_balance,
                    size: 16,
                    color: AppColors.textPrimary.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    credit.bankName?.isNotEmpty == true ? credit.bankName! : 'Не указан',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getCreditTypeColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getCreditTypeText(),
                      style: TextStyle(
                        color: _getCreditTypeColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Основные показатели
              Row(
                children: [
                  Expanded(
                    child: _buildMetric(
                      'Остаток долга',
                      '${credit.currentBalance.toStringAsFixed(0)} ₽',
                      Icons.account_balance_wallet,
                      AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetric(
                      'Ежемесячный платеж',
                      '${credit.monthlyPayment.toStringAsFixed(0)} ₽',
                      Icons.payment,
                      AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Прогресс погашения
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Прогресс погашения',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}%',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.background,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Погашено: ${remainingDebt.toStringAsFixed(0)} ₽',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12,
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        'Переплата: ${overpayment.toStringAsFixed(0)} ₽',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Следующий платеж
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textPrimary.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Следующий платеж: ',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 14,
                      color: AppColors.textPrimary.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    DateFormat('dd.MM.yyyy').format(credit.nextPaymentDate),
                    style: AppTextStyles.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _isPaymentOverdue() ? AppColors.error : AppColors.primary,
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

  Widget _buildStatusChip() {
    Color color;
    String text;
    IconData icon;

    switch (credit.status) {
      case CreditStatus.active:
        color = AppColors.success;
        text = 'Активен';
        icon = Icons.check_circle;
        break;
      case CreditStatus.overdue:
        color = AppColors.error;
        text = 'Просрочен';
        icon = Icons.warning;
        break;
      case CreditStatus.paid:
        color = AppColors.textPrimary.withOpacity(0.5);
        text = 'Погашен';
        icon = Icons.cancel;
        break;
      default:
        color = AppColors.warning;
        text = 'Неизвестно';
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String title, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              title,
              style: AppTextStyles.body.copyWith(
                fontSize: 12,
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getCreditTypeColor() {
    switch (credit.type) {
      case CreditType.consumer:
        return const Color(0xFF4CAF50);
      case CreditType.mortgage:
        return const Color(0xFF2196F3);
      case CreditType.microloan:
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _getCreditTypeText() {
    switch (credit.type) {
      case CreditType.consumer:
        return 'Потребительский';
      case CreditType.mortgage:
        return 'Ипотека';
      case CreditType.microloan:
        return 'Микрозайм';
      default:
        return 'Неизвестно';
    }
  }

  bool _isPaymentOverdue() {
    return credit.nextPaymentDate.isBefore(DateTime.now());
  }

  void _showCreditDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildCreditDetailsSheet(context),
    );
  }

  Widget _buildCreditDetailsSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                credit.name,
                style: AppTextStyles.heading1,
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildDetailRow('Банк', credit.bankName?.isNotEmpty == true ? credit.bankName! : 'Не указан'),
          _buildDetailRow('Тип кредита', _getCreditTypeText()),
          _buildDetailRow('Начальная сумма', '${credit.initialAmount.toStringAsFixed(0)} ₽'),
          _buildDetailRow('Текущий остаток', '${credit.currentBalance.toStringAsFixed(0)} ₽'),
          _buildDetailRow('Ежемесячный платеж', '${credit.monthlyPayment.toStringAsFixed(0)} ₽'),
          _buildDetailRow('Процентная ставка', '${credit.interestRate.toStringAsFixed(1)}%'),
          _buildDetailRow('Следующий платеж', DateFormat('dd.MM.yyyy').format(credit.nextPaymentDate)),
          _buildDetailRow('Статус', _getStatusText()),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Редактирование кредита
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Редактировать'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Просмотр платежей
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text('Платежи'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (credit.status) {
      case CreditStatus.active:
        return 'Активен';
      case CreditStatus.paid:
        return 'Погашен';
      case CreditStatus.overdue:
        return 'Просрочен';
      case CreditStatus.defaulted:
        return 'Дефолт';
      default:
        return 'Неизвестно';
    }
  }
}

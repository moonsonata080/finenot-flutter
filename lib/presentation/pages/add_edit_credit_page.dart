import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/credits_controller.dart';
import '../../data/models/credit.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';

class AddEditCreditPage extends StatefulWidget {
  const AddEditCreditPage({super.key});

  @override
  State<AddEditCreditPage> createState() => _AddEditCreditPageState();
}

class _AddEditCreditPageState extends State<AddEditCreditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _initialAmountController = TextEditingController();
  final _monthlyPaymentController = TextEditingController();
  final _interestRateController = TextEditingController();
  
  CreditType _selectedType = CreditType.consumer;
  DateTime _nextPaymentDate = DateTime.now().add(const Duration(days: 30));
  bool _isEditMode = false;
  Credit? _editingCredit;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final arguments = Get.arguments;
    if (arguments != null && arguments is Credit) {
      _editingCredit = arguments;
      _isEditMode = true;
      _populateForm();
    }
  }

  void _populateForm() {
    if (_editingCredit != null) {
      _nameController.text = _editingCredit!.name;
      _bankNameController.text = _editingCredit!.bankName ?? '';
      _initialAmountController.text = _editingCredit!.initialAmount.toString();
      _monthlyPaymentController.text = _editingCredit!.monthlyPayment.toString();
      _interestRateController.text = _editingCredit!.interestRate.toString();
      _selectedType = _editingCredit!.type;
      _nextPaymentDate = _editingCredit!.nextPaymentDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bankNameController.dispose();
    _initialAmountController.dispose();
    _monthlyPaymentController.dispose();
    _interestRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreditsController>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Редактировать кредит' : 'Добавить кредит',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Credit name
              _buildTextField(
                controller: _nameController,
                label: 'Название кредита',
                hint: 'Например: Ипотека на квартиру',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название кредита';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Bank name
              _buildTextField(
                controller: _bankNameController,
                label: 'Банк (необязательно)',
                hint: 'Например: Сбербанк',
              ),
              const SizedBox(height: 16),

              // Credit type
              _buildDropdownField(
                label: 'Тип кредита',
                value: _selectedType,
                items: CreditType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(controller.getCreditTypeName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Initial amount
              _buildTextField(
                controller: _initialAmountController,
                label: 'Начальная сумма',
                hint: '1000000',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите начальную сумму';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Введите корректную сумму';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Monthly payment
              _buildTextField(
                controller: _monthlyPaymentController,
                label: 'Ежемесячный платеж',
                hint: '50000',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите ежемесячный платеж';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Введите корректную сумму';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Interest rate
              _buildTextField(
                controller: _interestRateController,
                label: 'Процентная ставка (%)',
                hint: '7.5',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите процентную ставку';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Введите корректную ставку';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Next payment date
              _buildDateField(
                label: 'Дата следующего платежа',
                value: _nextPaymentDate,
                onChanged: (date) {
                  setState(() {
                    _nextPaymentDate = date;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Submit button
              Obx(() => ElevatedButton(
                onPressed: controller.isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isEditMode ? 'Сохранить' : 'Добавить кредит',
                        style: AppTextStyles.body,
                      ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required dynamic value,
    required List<DropdownMenuItem> items,
    required Function(dynamic) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonFormField(
            value: value,
            items: items,
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required Function(DateTime) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
            );
            if (date != null) {
              onChanged(date);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Text(
                  '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final credit = Credit(
        id: _editingCredit?.id ?? 0,
        name: _nameController.text.trim(),
        bankName: _bankNameController.text.trim().isEmpty ? null : _bankNameController.text.trim(),
        createdAt: _editingCredit?.createdAt ?? DateTime.now(),
        initialAmount: double.parse(_initialAmountController.text),
        currentBalance: double.parse(_initialAmountController.text),
        monthlyPayment: double.parse(_monthlyPaymentController.text),
        interestRate: double.parse(_interestRateController.text),
        nextPaymentDate: _nextPaymentDate,
        status: CreditStatus.active,
        type: _selectedType,
      );

      final controller = Get.find<CreditsController>();
      
      if (_isEditMode) {
        credit.id = _editingCredit!.id;
        credit.createdAt = _editingCredit!.createdAt;
        controller.updateCredit(credit);
      } else {
        controller.addCredit(credit);
      }
    }
  }
}

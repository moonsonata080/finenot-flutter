import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/credits_controller.dart';
import '../controllers/org_picker_controller.dart';
import '../../data/models/credit.dart';
import '../../data/models/org.dart';

class AddEditCreditPage extends StatefulWidget {
  final String? creditId; // null for new credit, not null for editing

  const AddEditCreditPage({super.key, this.creditId});

  @override
  State<AddEditCreditPage> createState() => _AddEditCreditPageState();
}

class _AddEditCreditPageState extends State<AddEditCreditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _initialAmountController = TextEditingController();
  final _monthlyPaymentController = TextEditingController();
  final _interestRateController = TextEditingController();
  
  String _selectedType = 'consumer';
  String _selectedStatus = 'active';
  Org? _selectedOrg;
  DateTime _nextPaymentDate = DateTime.now().add(const Duration(days: 30));
  
  final CreditsController _creditsController = Get.find<CreditsController>();
  final OrgPickerController _orgController = Get.find<OrgPickerController>();
  
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.creditId != null;
    if (_isEditing) {
      _loadCreditData();
    }
    _loadOrganizations();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialAmountController.dispose();
    _monthlyPaymentController.dispose();
    _interestRateController.dispose();
    super.dispose();
  }

  Future<void> _loadCreditData() async {
    if (widget.creditId == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final credit = await _creditsController.getCreditById(widget.creditId!);
      if (credit != null) {
        _nameController.text = credit.name;
        _initialAmountController.text = credit.initialAmount.toString();
        _monthlyPaymentController.text = credit.monthlyPayment.toString();
        _interestRateController.text = credit.interestRate.toString();
        _selectedType = credit.type;
        _selectedStatus = credit.status;
        _nextPaymentDate = credit.nextPaymentDate;
        
        if (credit.orgId != null) {
          final org = await _orgController.getOrgById(credit.orgId!);
          if (org != null) {
            _selectedOrg = org;
          }
        }
      }
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Не удалось загрузить данные кредита: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadOrganizations() async {
    try {
      await _orgController.loadOrganizations();
    } catch (e) {
      print('Error loading organizations: $e');
    }
  }

  Future<void> _selectOrganization() async {
    final result = await Get.to(() => const OrgPickerPage());
    if (result != null && result is Org) {
      setState(() {
        _selectedOrg = result;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextPaymentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _nextPaymentDate = picked;
      });
    }
  }

  Future<void> _saveCredit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final credit = Credit(
        name: _nameController.text.trim(),
        type: _selectedType,
        orgId: _selectedOrg?.key,
        initialAmount: double.parse(_initialAmountController.text),
        currentBalance: double.parse(_initialAmountController.text), // For new credit, balance = initial amount
        monthlyPayment: double.parse(_monthlyPaymentController.text),
        interestRate: double.parse(_interestRateController.text),
        nextPaymentDate: _nextPaymentDate,
        status: _selectedStatus,
        createdAt: DateTime.now(),
      );

      bool success;
      if (_isEditing) {
        success = await _creditsController.updateCredit(widget.creditId!, credit);
      } else {
        success = await _creditsController.createCredit(credit);
      }

      if (success) {
        Get.snackbar(
          'Успешно',
          _isEditing ? 'Кредит обновлен' : 'Кредит создан',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.back();
      } else {
        Get.snackbar(
          'Ошибка',
          'Не удалось сохранить кредит',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Ошибка при сохранении: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактировать кредит' : 'Новый кредит'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteDialog,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic information section
                    _buildSectionHeader('Основная информация'),
                    _buildNameField(),
                    const SizedBox(height: 16),
                    
                    // Credit type and organization
                    Row(
                      children: [
                        Expanded(child: _buildTypeField()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatusField()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildOrganizationField(),
                    const SizedBox(height: 24),
                    
                    // Financial information section
                    _buildSectionHeader('Финансовая информация'),
                    _buildInitialAmountField(),
                    const SizedBox(height: 16),
                    _buildMonthlyPaymentField(),
                    const SizedBox(height: 16),
                    _buildInterestRateField(),
                    const SizedBox(height: 24),
                    
                    // Payment schedule section
                    _buildSectionHeader('График платежей'),
                    _buildNextPaymentDateField(),
                    const SizedBox(height: 24),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveCredit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(_isEditing ? 'Обновить' : 'Создать'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Название кредита',
        hintText: 'Например: Ипотека на квартиру',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Введите название кредита';
        }
        return null;
      },
    );
  }

  Widget _buildTypeField() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      decoration: const InputDecoration(
        labelText: 'Тип кредита',
        border: OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(value: 'consumer', child: Text(_getTypeDisplayName('consumer'))),
        DropdownMenuItem(value: 'mortgage', child: Text(_getTypeDisplayName('mortgage'))),
        DropdownMenuItem(value: 'micro', child: Text(_getTypeDisplayName('micro'))),
        DropdownMenuItem(value: 'card', child: Text(_getTypeDisplayName('card'))),
      ],
      onChanged: (value) {
        setState(() {
          _selectedType = value!;
        });
      },
    );
  }

  Widget _buildStatusField() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: const InputDecoration(
        labelText: 'Статус',
        border: OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(value: 'active', child: Text(_getStatusDisplayName('active'))),
        DropdownMenuItem(value: 'closed', child: Text(_getStatusDisplayName('closed'))),
        DropdownMenuItem(value: 'overdue', child: Text(_getStatusDisplayName('overdue'))),
      ],
      onChanged: (value) {
        setState(() {
          _selectedStatus = value!;
        });
      },
    );
  }

  Widget _buildOrganizationField() {
    return InkWell(
      onTap: _selectOrganization,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(Icons.account_balance),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Организация',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    _selectedOrg?.displayName ?? 'Выберите банк или МФО',
                    style: TextStyle(
                      color: _selectedOrg != null ? null : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialAmountField() {
    return TextFormField(
      controller: _initialAmountController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Начальная сумма',
        suffixText: '₽',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Введите сумму';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Введите корректную сумму';
        }
        return null;
      },
    );
  }

  Widget _buildMonthlyPaymentField() {
    return TextFormField(
      controller: _monthlyPaymentController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Ежемесячный платеж',
        suffixText: '₽',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Введите сумму платежа';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Введите корректную сумму';
        }
        return null;
      },
    );
  }

  Widget _buildInterestRateField() {
    return TextFormField(
      controller: _interestRateController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Процентная ставка',
        suffixText: '%',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Введите процентную ставку';
        }
        final rate = double.tryParse(value);
        if (rate == null || rate < 0 || rate > 100) {
          return 'Введите корректную ставку';
        }
        return null;
      },
    );
  }

  Widget _buildNextPaymentDateField() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Дата следующего платежа',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${_nextPaymentDate.day}.${_nextPaymentDate.month}.${_nextPaymentDate.year}',
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить кредит'),
        content: const Text('Вы уверены, что хотите удалить этот кредит? Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              setState(() => _isLoading = true);
              try {
                final success = await _creditsController.deleteCredit(widget.creditId!);
                if (success) {
                  Get.snackbar(
                    'Успешно',
                    'Кредит удален',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  Get.back();
                }
              } catch (e) {
                Get.snackbar(
                  'Ошибка',
                  'Не удалось удалить кредит: $e',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } finally {
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  String _getTypeDisplayName(String type) {
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

// Simple OrgPickerPage for organization selection
class OrgPickerPage extends StatelessWidget {
  const OrgPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OrgPickerController controller = Get.find<OrgPickerController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор организации'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: controller.setSearchQuery,
              decoration: const InputDecoration(
                labelText: 'Поиск',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          
          // Organizations list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredOrgs.isEmpty) {
                return const Center(
                  child: Text('Организации не найдены'),
                );
              }

              return ListView.builder(
                itemCount: controller.filteredOrgs.length,
                itemBuilder: (context, index) {
                  final org = controller.filteredOrgs[index];
                  return ListTile(
                    title: Text(org.displayName),
                    subtitle: Text(org.type == 'bank' ? 'Банк' : 'МФО'),
                    trailing: Text(org.bic ?? org.ogrn ?? ''),
                    onTap: () => Get.back(result: org),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

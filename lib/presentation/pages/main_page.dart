import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_page.dart';
import 'credits_page.dart';
import 'payments_page.dart';
import 'settings_page.dart';
import 'add_edit_credit_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const HomePage(),
    const CreditsPage(),
    const PaymentsPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card),
            label: 'Кредиты',
          ),
          NavigationDestination(
            icon: Icon(Icons.payment),
            label: 'Платежи',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_currentIndex) {
      case 1: // Credits page
        return FloatingActionButton(
          onPressed: () => Get.to(() => const AddEditCreditPage()),
          child: const Icon(Icons.add),
        );
      case 2: // Payments page
        return FloatingActionButton(
          onPressed: () => _showAddPaymentDialog(),
          child: const Icon(Icons.add),
        );
      default:
        return null;
    }
  }

  void _showAddPaymentDialog() {
    Get.snackbar(
      'Информация',
      'Добавление платежей будет доступно в следующей версии',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

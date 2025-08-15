import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

void main() {
  // Обеспечиваем инициализацию Flutter binding
  WidgetsFlutterBinding.ensureInitialized();
  
  // Устанавливаем системные настройки
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Устанавливаем ориентацию экрана
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Запускаем приложение с обработкой ошибок
  runZonedGuarded(() {
    runApp(const FinEnotApp());
  }, (error, stack) {
    print('Error in main: $error');
    print('Stack trace: $stack');
  });
}

class FinEnotApp extends StatelessWidget {
  const FinEnotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FinEnot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        primaryColor: const Color(0xFFFF8C00),
        scaffoldBackgroundColor: const Color(0xFFFFF8F0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF8C00),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8C00),
          background: const Color(0xFFFFF8F0),
        ),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const CreditsPage(),
    const PaymentsPage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    print('DashboardPage initialized');
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFFFF8C00),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Кредиты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Платежи',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FinEnot',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8F0),
              Colors.white,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 120,
                color: Color(0xFFFF8C00),
              ),
              SizedBox(height: 30),
              Text(
                'FinEnot',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8C00),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Менеджер кредитов и микрозаймов',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 80,
                        color: Colors.green,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Приложение успешно запущено!',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Все зависимости подключены',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Версия: 1.0.0',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Кредиты'),
      ),
      body: const Center(
        child: Text(
          'Страница кредитов',
          style: TextStyle(fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Добавить кредит
        },
        backgroundColor: const Color(0xFFFF8C00),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Платежи'),
      ),
      body: const Center(
        child: Text(
          'Страница платежей',
          style: TextStyle(fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Добавить платеж
        },
        backgroundColor: const Color(0xFFFF8C00),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.notifications, color: Color(0xFFFF8C00)),
            title: const Text('Уведомления'),
            subtitle: const Text('Настройка уведомлений'),
            onTap: () {
              // Настройки уведомлений
            },
          ),
          ListTile(
            leading: const Icon(Icons.security, color: Color(0xFFFF8C00)),
            title: const Text('Безопасность'),
            subtitle: const Text('PIN-код и биометрия'),
            onTap: () {
              // Настройки безопасности
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup, color: Color(0xFFFF8C00)),
            title: const Text('Резервные копии'),
            subtitle: const Text('Экспорт и импорт данных'),
            onTap: () {
              // Резервные копии
            },
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Color(0xFFFF8C00)),
            title: const Text('О приложении'),
            subtitle: const Text('Версия 1.0.0'),
            onTap: () {
              // О приложении
            },
          ),
        ],
      ),
    );
  }
}

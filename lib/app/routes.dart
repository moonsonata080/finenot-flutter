import 'package:get/get.dart';
import '../presentation/pages/splash_page.dart';
import '../presentation/pages/lock_page.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/credits_page.dart';
import '../presentation/pages/add_edit_credit_page.dart';
import '../presentation/pages/payments_page.dart';
import '../presentation/pages/calendar_page.dart';
import '../presentation/pages/settings_page.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String lock = '/lock';
  static const String home = '/home';
  static const String credits = '/credits';
  static const String addCredit = '/add-credit';
  static const String editCredit = '/edit-credit';
  static const String payments = '/payments';
  static const String calendar = '/calendar';
  static const String settings = '/settings';

  static final List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => const SplashPage(),
      transition: Transition.fade,
    ),
    GetPage(
      name: lock,
      page: () => const LockPage(),
      transition: Transition.fade,
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: credits,
      page: () => const CreditsPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: addCredit,
      page: () => const AddEditCreditPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: editCredit,
      page: () => const AddEditCreditPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: payments,
      page: () => const PaymentsPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: calendar,
      page: () => const CalendarPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: settings,
      page: () => const SettingsPage(),
      transition: Transition.rightToLeft,
    ),
  ];
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/app.dart';
import 'data/db/isar_provider.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Isar database
  await IsarProvider.initialize();

  // Initialize notification service
  await NotificationService.initialize();

  runApp(const FinEnotApp());
}

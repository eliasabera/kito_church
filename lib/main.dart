import 'package:flutter/material.dart';
import 'package:kitoapp/app.dart';
import 'package:kitoapp/shared/services/database/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.initialize();
  runApp(const KitoApp());
}

import 'package:flutter/material.dart';
import 'package:kitoapp/app.dart';
import 'package:kitoapp/core/config/supabase_config.dart';
import 'package:kitoapp/shared/services/database/app_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.initialize();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );
  runApp(const KitoApp());
}

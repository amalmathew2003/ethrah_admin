import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'admin_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const EthrahAdminApp());
}

class EthrahAdminApp extends StatelessWidget {
  const EthrahAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ethrah Admin',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF4A342E), // darkBrown
        scaffoldBackgroundColor: const Color(0xFFFAF9F6), // ivory
        useMaterial3: true,
      ),
      home: const AdminHomeScreen(),
    );
  }
}

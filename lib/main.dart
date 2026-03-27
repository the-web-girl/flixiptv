import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/iptv_provider.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FlixIptvApp());
}

class FlixIptvApp extends StatelessWidget {
  const FlixIptvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IptvProvider(),
      child: MaterialApp(
        title: 'FlixIPTV',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const HomeScreen(),
      ),
    );
  }
}
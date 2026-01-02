import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_campus/screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Campus',
      home: AuthScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
      },
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
    );
  }
}

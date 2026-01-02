import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Smart Campus!'),
            ElevatedButton(
              onPressed: () {
                // Тест gRPC соединения
                testGrpcConnection();
              },
              child: const Text('Test gRPC Connection'),
            ),
          ],
        ),
      ),
    );
  }

  void testGrpcConnection() async {
    // Добавьте тестовый вызов gRPC здесь
  }
}

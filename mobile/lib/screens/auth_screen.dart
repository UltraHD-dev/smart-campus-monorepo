import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedRole = 'student';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isAuthenticated) {
      // Если пользователь авторизован, показываем главный экран
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Campus Auth'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Login'),
            Tab(text: 'Register'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: TabBarView(
          controller: _tabController,
          children: [
            // LOGIN TAB
            _buildLoginForm(authProvider),
            // REGISTER TAB
            _buildRegisterForm(authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(AuthProvider authProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (authProvider.error != null)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 20),
              color: Colors.red[100],
              child: Text(
                authProvider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 30),
          if (authProvider.isLoading)
            const CircularProgressIndicator()
          else
            ElevatedButton(
              onPressed: () {
                authProvider.login(
                  _emailController.text.trim(),
                  _passwordController.text,
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                child: Text('Login', style: TextStyle(fontSize: 18)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(AuthProvider authProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (authProvider.error != null)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 20),
              color: Colors.red[100],
              child: Text(
                authProvider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: const InputDecoration(
              labelText: 'Role',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.assignment_ind),
            ),
            items: ['student', 'teacher', 'admin']
                .map(
                  (role) => DropdownMenuItem(
                    value: role,
                    child: Text(role.toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedRole = value!;
              });
            },
          ),
          const SizedBox(height: 30),
          if (authProvider.isLoading)
            const CircularProgressIndicator()
          else
            ElevatedButton(
              onPressed: () {
                authProvider.register(
                  _emailController.text.trim(),
                  _passwordController.text,
                  _nameController.text.trim(),
                  _selectedRole,
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                child: Text('Register', style: TextStyle(fontSize: 18)),
              ),
            ),
        ],
      ),
    );
  }
}

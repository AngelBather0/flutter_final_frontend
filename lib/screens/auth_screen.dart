import 'package:flutter/material.dart';
import 'login_form.dart';
import 'register_form.dart';
import 'services_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool showLogin = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        showLogin = _tabController.index == 0;
      });
    }
  }

  void toggleView() {
    setState(() {
      showLogin = !showLogin;
      _tabController.animateTo(showLogin ? 0 : 1);
    });
  }

  void _navigateToServices(String token, String userId, BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ServicesScreen(token: token, userId: userId),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFC9B037),
                indicatorWeight: 3,
                labelColor: const Color(0xFFC9B037),
                unselectedLabelColor: Colors.black,
                tabs: const [
                  Tab(text: 'INICIAR SESIÓN'),
                  Tab(text: 'REGISTRARSE'),
                ],
              ),
              const SizedBox(height: 30),
              if (showLogin)
                LoginForm(
                  onLoginSuccess: (token, userId) => _navigateToServices(token, userId, context),
                )
              else
                RegisterForm(
                  onRegisterSuccess: (token, userId) => _navigateToServices(token, userId, context),
                ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: toggleView,
                child: Text(
                  showLogin
                      ? '¿No tienes cuenta? Regístrate aquí'
                      : '¿Ya tienes cuenta? Inicia sesión',
                  style: const TextStyle(color: Color(0xFFC9B037)),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.facebook, color: Colors.white),
                label: Text(
                  showLogin ? 'Inicia con Facebook' : 'Regístrate con Facebook',
                  style: const TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  // Implementar lógica de Facebook
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
              ),
              if (showLogin) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    // Navegar a pantalla de recuperación de contraseña
                  },
                  child: const Text(
                    '¿Olvidaste tu contraseña? Click aquí',
                    style: TextStyle(color: Color(0xFFC9B037)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // Añade este import
import 'screens/auth_screen.dart';

void main() async {
  // Añade estas líneas para inicializar el formato de fechas
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null); // Inicializa para español

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barber App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthScreen(),
    );
  }
}
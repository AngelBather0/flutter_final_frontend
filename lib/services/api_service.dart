import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';

class ApiService {
  static const String _baseUrl = 'http://10.0.0.24:8080';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/signin');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error en el login: ${response.statusCode}');
    }
  }


  static Future<Map<String, dynamic>> register(
      String name,
      String email,
      String password,
      String role, // 'client' o 'provider'
      ) async {
    final url = Uri.parse('$_baseUrl/auth/signup');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': name,
        'email': email,
        'role': role, // Usamos el rol seleccionado
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error en el registro: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    // Decodificar el token JWT para obtener el userId
    final payload = JwtDecoder.decode(token);
    final userId = payload['userId']?.toString();

    if (userId == null) {
      throw Exception('El token JWT no contiene userId');
    }

    final url = Uri.parse('$_baseUrl/user/$userId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener perfil: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> getServices(String token, bool isProvider) async {
    final endpoint = isProvider ? 'services' : 'services/get/all';
    final url = Uri.parse('$_baseUrl/$endpoint');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener servicios: ${response.statusCode}');
    }
  }

  static Future<void> createService(
      String token,
      String name,
      bool isRefundable,
      int price,
      String providerId,
      ) async {
    final url = Uri.parse('$_baseUrl/services');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'is_refundable': isRefundable,
        'price': price,
        'provider_id': providerId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear servicio: ${response.statusCode}');
    }
  }

  static Future<void> updateService(
      String token,
      String serviceId,
      String name,
      bool isRefundable,
      int price,
      ) async {
    final url = Uri.parse('$_baseUrl/services/$serviceId');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'is_refundable': isRefundable,
        'price': price,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar servicio: ${response.statusCode}');
    }
  }

  static Future<void> deleteService(String token, String serviceId) async {
    final url = Uri.parse('$_baseUrl/services/$serviceId');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar servicio: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> getClientAppointments(String token) async {
    final url = Uri.parse('$_baseUrl/appointment');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener citas: ${response.statusCode}');
    }
  }

  static Future<dynamic> createAppointment(
      String token,
      DateTime startsAt,
      String paymentMethod,
      int serviceId, {
        String? card,
      }) async {
    final url = Uri.parse('$_baseUrl/appointment');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'starts_at': startsAt.toIso8601String(),
        'payment_method': paymentMethod,
        'service_id': serviceId,
        if (card != null) 'card': card,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear reserva: ${response.statusCode}');
    }
  }

  static Future<void> confirmAppointment(String token, String appointmentId) async {
    final url = Uri.parse('$_baseUrl/appointment/confirm?appointment_id=$appointmentId');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al confirmar reserva: ${response.statusCode}');
    }
  }

  static Future<void> cancelAppointment(String token, String appointmentId) async {
    final url = Uri.parse('$_baseUrl/appointment/cancel?appointment_id=$appointmentId');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );


    if (response.statusCode != 200) {
      throw Exception('Error al cancelar reserva: ${response.statusCode}');
    }
  }

}
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kalilu/models/driver.dart';
import 'package:kalilu/models/route.dart';
import 'package:kalilu/models/booking.dart';

class ApiService {
  static const String baseUrl = 'https://api.kalilu.ec';
  
  // Headers para Ecuador
  static final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Accept-Language': 'es-EC',
  };

  // ===== AUTHENTICATION =====
  
  static Future<String> login(String phone, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: headers,
      body: jsonEncode({
        'phone': phone,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw Exception('Error de autenticación');
    }
  }

  static Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
        'role': role,
        'country_code': '+593',
      }),
    );
    
    if (response.statusCode != 201) {
      throw Exception('Error al registrar');
    }
  }

  // ===== DRIVERS =====
  
  static Future<List<Driver>> getDrivers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/drivers'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Driver.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener conductores');
    }
  }

  static Future<Driver> getDriverProfile(String driverId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/drivers/$driverId'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return Driver.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener perfil');
    }
  }

  static Future<void> updateDriverVerification(String driverId, bool verified) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/drivers/$driverId/verify'),
      headers: headers,
      body: jsonEncode({'verified': verified}),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar verificación');
    }
  }

  // ===== ROUTES =====
  
  static Future<List<Route>> getRoutes({
    String? destination,
    DateTime? date,
    double? maxPrice,
  }) async {
    final params = <String, String>{};
    if (destination != null) params['destination'] = destination;
    if (date != null) params['date'] = date.toIso8601String();
    if (maxPrice != null) params['max_price'] = maxPrice.toString();
    
    final uri = Uri.parse('$baseUrl/routes').replace(queryParameters: params);
    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Route.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener rutas');
    }
  }

  static Future<Route> createRoute({
    required String driverId,
    required String destination,
    required DateTime departureTime,
    required int totalSeats,
    required double price,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/routes'),
      headers: headers,
      body: jsonEncode({
        'driver_id': driverId,
        'destination': destination,
        'departure_time': departureTime.toIso8601String(),
        'total_seats': totalSeats,
        'price': price,
        'currency': 'USD',
      }),
    );
    
    if (response.statusCode == 201) {
      return Route.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear ruta');
    }
  }

  static Future<void> cancelRoute(String routeId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/routes/$routeId'),
      headers: headers,
    );
    
    if (response.statusCode != 200) {
      throw Exception('Error al cancelar ruta');
    }
  }

  // ===== BOOKINGS =====
  
  static Future<List<Booking>> getBookings(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookings?user_id=$userId'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Booking.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener reservas');
    }
  }

  static Future<Booking> createBooking({
    required String routeId,
    required String userName,
    required String userPhone,
    required String pickupLocation,
    required int seatNumber,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: headers,
      body: jsonEncode({
        'route_id': routeId,
        'user_name': userName,
        'user_phone': userPhone,
        'pickup_location': pickupLocation,
        'seat_number': seatNumber,
      }),
    );
    
    if (response.statusCode == 201) {
      return Booking.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear reserva');
    }
  }

  static Future<void> cancelBooking(String bookingId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/bookings/$bookingId'),
      headers: headers,
    );
    
    if (response.statusCode != 200) {
      throw Exception('Error al cancelar reserva');
    }
  }

  // ===== ECUADOR-SPECIFIC ENDPOINTS =====
  
  static Future<List<String>> getEcuadorianCities() async {
    final response = await http.get(
      Uri.parse('$baseUrl/locations/ecuador/cities'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return List<String>.from(data);
    } else {
      return ['Quito', 'Guayaquil', 'Cuenca', 'Manta', 'Ambato'];
    }
  }

  static Future<double> getExchangeRate() async {
    // Ecuador usa USD, pero podrías integrar con servicios locales
    return 1.0; // 1 USD = 1 USD
  }

  // ===== ERROR HANDLING =====
  
  static String handleError(dynamic error) {
    if (error is SocketException) {
      return 'Error de conexión. Verifica tu internet.';
    } else if (error is FormatException) {
      return 'Error en el formato de datos.';
    } else {
      return 'Error: ${error.toString()}';
    }
  }

  // ===== AUTH TOKEN MANAGEMENT =====
  
  static String? _authToken;
  
  static void setAuthToken(String token) {
    _authToken = token;
    headers['Authorization'] = 'Bearer $token';
  }
  
  static void clearAuthToken() {
    _authToken = null;
    headers.remove('Authorization');
  }
}

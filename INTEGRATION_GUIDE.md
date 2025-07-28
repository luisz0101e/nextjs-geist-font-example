# KALILU - Guía de Integración Real

## 🚀 **Pasos para Integración con Backend Real**

### **1. Configuración del Backend (Ecuador)**

#### **Backend API Requirements:**
```yaml
# Requisitos del servidor
- Ubicación: Ecuador (AWS/Google Cloud)
- Dominio: api.kalilu.ec
- SSL: Certificado SSL válido
- Base de datos: PostgreSQL/MySQL
- Moneda: USD (dólares)
- Zona horaria: America/Guayaquil
```

#### **Endpoints Necesarios:**

**Autenticación:**
```
POST /auth/login
POST /auth/register
POST /auth/logout
POST /auth/refresh
```

**Conductores:**
```
GET /drivers
GET /drivers/:id
PATCH /drivers/:id/verify
PUT /drivers/:id/profile
```

**Rutas:**
```
GET /routes
POST /routes
GET /routes/:id
PATCH /routes/:id
DELETE /routes/:id
GET /routes/search
```

**Reservas:**
```
GET /bookings
POST /bookings
GET /bookings/:id
DELETE /bookings/:id
```

### **2. Configuración de Base de Datos**

#### **Esquema de Base de Datos:**

```sql
-- Tabla de usuarios (conductores y pasajeros)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20) UNIQUE NOT NULL,
    country_code VARCHAR(5) DEFAULT '+593',
    role VARCHAR(20) CHECK (role IN ('driver', 'passenger', 'admin')),
    is_verified BOOLEAN DEFAULT FALSE,
    rating DECIMAL(3,2) DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de rutas
CREATE TABLE routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID REFERENCES users(id),
    destination VARCHAR(255) NOT NULL,
    departure_time TIMESTAMP NOT NULL,
    available_seats INTEGER NOT NULL CHECK (available_seats > 0),
    total_seats INTEGER NOT NULL CHECK (total_seats > 0),
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    currency VARCHAR(3) DEFAULT 'USD',
    status VARCHAR(20) CHECK (status IN ('active', 'full', 'completed', 'cancelled')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de reservas
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    route_id UUID REFERENCES routes(id),
    user_id UUID REFERENCES users(id),
    user_name VARCHAR(255) NOT NULL,
    user_phone VARCHAR(20) NOT NULL,
    pickup_location VARCHAR(255) NOT NULL,
    seat_number INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'confirmed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para Ecuador
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_routes_destination ON routes(destination);
CREATE INDEX idx_routes_departure ON routes(departure_time);
CREATE INDEX idx_bookings_route ON bookings(route_id);
```

### **3. Configuración de API Service**

#### **Actualizar ApiService para producción:**

```dart
// En lib/services/api_service.dart
// Cambiar baseUrl a producción:
static const String baseUrl = 'https://api.kalilu.ec';
// static const String baseUrl = 'http://localhost:3000'; // Para desarrollo
```

#### **Variables de entorno:**
```dart
// Crear archivo: lib/config/environment.dart
class Environment {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.kalilu.ec',
  );
  
  static const String websocketUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'wss://api.kalilu.ec/ws',
  );
}
```

### **4. Integración con Servicios Ecuadorianos**

#### **Servicios de Ubicación:**
```dart
// Integración con Google Maps Ecuador
// API Key para Ecuador
const googleMapsApiKey = 'TU_API_KEY_ECUADOR';

// Servicios de geocoding para Ecuador
class EcuadorLocationService {
  static Future<List<String>> getEcuadorianCities() async {
    return ['Quito', 'Guayaquil', 'Cuenca', 'Manta', 'Ambato', 'Loja'];
  }
  
  static Future<List<String>> getQuitoNeighborhoods() async {
    return ['La Mariscal', 'Centro Histórico', 'La Floresta', 'González Suárez'];
  }
}
```

### **5. Configuración de Notificaciones**

#### **Firebase Cloud Messaging (Ecuador):**
```dart
// lib/services/notification_service.dart
class NotificationService {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    
    // Configuración para Ecuador
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    // Tópicos específicos de Ecuador
    await messaging.subscribeToTopic('ecuador_routes');
    await messaging.subscribeToTopic('quito_notifications');
  }
}
```

### **6. Configuración de Pagos (Ecuador)**

#### **Integración con Pasarela de Pagos:**
```dart
// lib/services/payment_service.dart
class PaymentService {
  static Future<String> processPayment({
    required double amount,
    required String currency,
    required String phone,
  }) async {
    // Integración con servicios ecuatorianos
    // Ejemplo: PagoEcuador, Banco del Pacífico, etc.
    
    final response = await http.post(
      Uri.parse('$baseUrl/payments/process'),
      headers: headers,
      body: jsonEncode({
        'amount': amount,
        'currency': 'USD',
        'phone': phone,
        'country': 'EC',
      }),
    );
    
    return jsonDecode(response.body)['payment_id'];
  }
}
```

### **7. Configuración de Seguridad**

#### **Validaciones Ecuadorianas:**
```dart
// lib/utils/ecuador_validators.dart
class EcuadorValidators {
  static bool isValidEcuadorianPhone(String phone) {
    // Validar formato ecuatoriano: +593 9XXXXXXXX
    final regex = RegExp(r'^\+593\s?9\d{8}$');
    return regex.hasMatch(phone);
  }
  
  static bool isValidEcuadorianId(String id) {
    // Validar cédula ecuatoriana
    return id.length == 10;
  }
}
```

### **8. Configuración de Despliegue**

#### **Docker para Ecuador:**
```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

ENV NODE_ENV=production
ENV TZ=America/Guayaquil

CMD ["npm", "start"]
```

#### **docker-compose.yml:**
```yaml
version: '3.8'
services:
  api:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/kalilu
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: kalilu
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine

volumes:
  postgres_data:
```

### **9. Variables de Entorno**

#### **Archivo .env:**
```bash
# .env
API_BASE_URL=https://api.kalilu.ec
DATABASE_URL=postgresql://user:pass@localhost:5432/kalilu
REDIS_URL=redis://localhost:6379
JWT_SECRET=tu_secreto_jwt
GOOGLE_MAPS_API_KEY=tu_api_key_ecuador
FIREBASE_SERVER_KEY=tu_firebase_key
```

### **10. Comandos de Despliegue**

#### **Despliegue en AWS EC2 (Ecuador):**
```bash
# 1. Configurar servidor
ssh ec2-user@tu-servidor-ecuador
sudo yum update -y
sudo yum install docker -y

# 2. Clonar y desplegar
git clone https://github.com/tu-usuario/kalilu-backend.git
cd kalilu-backend
docker-compose up -d

# 3. Configurar dominio
sudo certbot --nginx -d api.kalilu.ec
```

### **11. Testing en Producción**

#### **Pruebas de Integración:**
```bash
# Test de API
curl -X POST https://api.kalilu.ec/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","phone":"+593987654321","email":"test@kalilu.ec","password":"123456"}'

# Test de rutas
curl -X GET https://api.kalilu.ec/routes?destination=Quito
```

### **12. Monitoreo y Logs**

#### **Configuración de Monitoreo:**
```yaml
# Configuración para Ecuador
monitoring:
  alerts:
    - name: "Servidor Ecuador"
      condition: "server_down"
      notification: "sms:+593987654321"
```

## 🚀 **Checklist de Integración**

- [ ] Configurar servidor en Ecuador
- [ ] Configurar base de datos con esquema ecuatoriano
- [ ] Configurar API endpoints
- [ ] Configurar autenticación
- [ ] Configurar notificaciones push
- [ ] Configurar pagos (USD)
- [ ] Configurar monitoreo
- [ ] Configurar dominio SSL
- [ ] Pruebas de integración
- [ ] Despliegue a producción

## 📞 **Soporte Técnico Ecuador**
- **WhatsApp**: +593 98 765 4321
- **Email**: soporte@kalilu.ec
- **Horario**: 8:00 - 18:00 (GMT-5)

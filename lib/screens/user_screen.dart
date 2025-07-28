import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kalilu/models/route.dart';
import 'package:kalilu/providers/app_provider.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final TextEditingController _destinationController = TextEditingController();
  DateTime? _selectedDateTime;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final routes = provider.getAvailableRoutes();
    final filteredRoutes = provider.searchRoutes(
      _destinationController.text,
      _selectedDateTime,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Rutas'),
        backgroundColor: const Color(0xFF1E88E5),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _destinationController,
                  decoration: const InputDecoration(
                    labelText: 'Destino',
                    hintText: 'Ej: Centro Comercial Quicentro',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          _selectedDateTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(
                          _selectedDateTime != null
                              ? DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateTime!)
                              : 'Seleccionar fecha y hora',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredRoutes.isEmpty
                ? const Center(
                    child: Text('No se encontraron rutas disponibles'),
                  )
                : ListView.builder(
                    itemCount: filteredRoutes.length,
                    itemBuilder: (context, index) {
                      final route = filteredRoutes[index];
                      return RouteCard(route: route);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }
}

class RouteCard extends StatelessWidget {
  final Route route;

  const RouteCard({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    route.destination,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '\$${route.price.toStringAsFixed(2)} USD',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16),
                const SizedBox(width: 4),
                Text(route.driver.name),
                const SizedBox(width: 16),
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text('${route.driver.rating}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Text(DateFormat('dd/MM HH:mm').format(route.departureTime)),
                const SizedBox(width: 16),
                const Icon(Icons.event_seat, size: 16),
                const SizedBox(width: 4),
                Text('${route.availableSeats}/${route.totalSeats} asientos'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (route.totalSeats - route.availableSeats) / route.totalSeats,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                route.availableSeats == 0 ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: route.availableSeats > 0
                    ? () => _showBookingDialog(context, route)
                    : null,
                child: Text(
                  route.availableSeats > 0
                      ? 'Reservar Asiento'
                      : 'Sin Asientos',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDialog(BuildContext context, Route route) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reservar Asiento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: Icon(Icons.phone),
                hintText: '+593 9XXXXXXXX',
              ),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Punto de recogida',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty &&
                  locationController.text.isNotEmpty) {
                provider.bookRoute(
                  routeId: route.id,
                  userName: nameController.text,
                  userPhone: phoneController.text,
                  pickupLocation: locationController.text,
                  seatNumber: route.totalSeats - route.availableSeats + 1,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reserva confirmada exitosamente'),
                  ),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}

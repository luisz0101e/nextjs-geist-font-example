import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kalilu/models/route.dart';
import 'package:kalilu/providers/app_provider.dart';
import 'package:provider/provider.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController(text: '4');
  DateTime? _selectedDateTime;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final activeRoute = provider.activeRoute;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel del Conductor'),
        backgroundColor: const Color(0xFF1E88E5),
      ),
      body: activeRoute == null
          ? _buildCreateRouteForm(provider)
          : _buildActiveRouteView(provider, activeRoute),
    );
  }

  Widget _buildCreateRouteForm(AppProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Crear Nueva Ruta',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: 'Destino *',
                hintText: 'Ej: Centro Comercial Quicentro',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un destino';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 7)),
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
                          : 'Seleccionar fecha y hora *',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _seatsController,
              decoration: const InputDecoration(
                labelText: 'Asientos disponibles *',
                prefixIcon: Icon(Icons.event_seat),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el número de asientos';
                }
                final seats = int.tryParse(value);
                if (seats == null || seats < 1 || seats > 8) {
                  return 'Los asientos deben estar entre 1 y 8';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Precio por asiento (USD) *',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
                hintText: '2.00',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el precio';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'El precio debe ser mayor a 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _selectedDateTime != null) {
                    provider.createRoute(
                      destination: _destinationController.text,
                      departureTime: _selectedDateTime!,
                      totalSeats: int.parse(_seatsController.text),
                      price: double.parse(_priceController.text),
                    );
                    _clearForm();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ruta creada exitosamente'),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Crear Ruta',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveRouteView(AppProvider provider, Route activeRoute) {
    final bookings = provider.getRouteBookings(activeRoute.id);
    final estimatedIncome = provider.getEstimatedIncome(activeRoute.id);
    final occupancy = (activeRoute.totalSeats - activeRoute.availableSeats) / activeRoute.totalSeats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ruta Activa',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text(
                          activeRoute.availableSeats == 0
                              ? 'Lleno'
                              : '${(occupancy * 100).toStringAsFixed(0)}% Lleno',
                        ),
                        backgroundColor: activeRoute.availableSeats == 0
                            ? Colors.red[100]
                            : Colors.green[100],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Destino', activeRoute.destination),
                  _buildDetailRow('Hora de salida', DateFormat('dd/MM HH:mm').format(activeRoute.departureTime)),
                  _buildDetailRow('Precio por asiento', '\$${activeRoute.price.toStringAsFixed(2)} USD'),
                  _buildDetailRow('Asientos ocupados', '${activeRoute.totalSeats - activeRoute.availableSeats}/${activeRoute.totalSeats}'),
                  _buildDetailRow('Ingresos estimados', '\$${estimatedIncome.toStringAsFixed(2)} USD'),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: occupancy,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      activeRoute.availableSeats == 0 ? Colors.red : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(
                      activeRoute.totalSeats,
                      (index) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: 40,
                          decoration: BoxDecoration(
                            color: index < activeRoute.totalSeats - activeRoute.availableSeats
                                ? Colors.red[100]
                                : Colors.green[100],
                            border: Border.all(
                              color: index < activeRoute.totalSeats - activeRoute.availableSeats
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: index < activeRoute.totalSeats - activeRoute.availableSeats
                                    ? Colors.red[800]
                                    : Colors.green[800],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reservas Confirmadas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (bookings.isEmpty)
                    const Text('Aún no hay reservas para esta ruta')
                  else
                    ...bookings.map((booking) => _buildBookingCard(booking)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Cancelar Ruta'),
                    content: const Text(
                      '¿Estás seguro de que quieres cancelar esta ruta? '
                      'Se notificará a todos los pasajeros.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () {
                          provider.cancelRoute();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ruta cancelada exitosamente'),
                            ),
                          );
                        },
                        child: const Text('Sí, Cancelar'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Cancelar Ruta'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(booking.seatNumber.toString()),
      ),
      title: Text(booking.userName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(booking.userPhone),
          Text(booking.pickupLocation),
        ],
      ),
      trailing: const Icon(Icons.check_circle, color: Colors.green),
    );
  }

  void _clearForm() {
    _destinationController.clear();
    _priceController.clear();
    _seatsController.text = '4';
    _selectedDateTime = null;
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _priceController.dispose();
    _seatsController.dispose();
    super.dispose();
  }
}

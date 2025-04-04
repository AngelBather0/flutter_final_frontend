import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/service_card.dart';
import '../widgets/appointment_card.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import 'auth_screen.dart';
import 'edit_service_screen.dart';
import 'create_appointment_screen.dart';

class ServicesScreen extends StatefulWidget {
  final String token;
  final String userId;

  const ServicesScreen({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _services = [];
  List<dynamic> _appointments = [];
  bool _isLoading = true;
  String _errorMessage = '';
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserAndServices();
  }

  Future<void> _loadUserAndServices() async {
    try {
      final userData = await ApiService.getUserProfile(widget.token);
      setState(() {
        _userProfile = UserProfile.fromJson(userData);
      });
      await _fetchServices();
      await _fetchAppointments();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final services = await ApiService.getServices(
        widget.token,
        _userProfile?.isProvider ?? false,
      );
      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAppointments() async {
    try {
      final appointments = await ApiService.getClientAppointments(widget.token);
      setState(() {
        _appointments = appointments;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar tus citas: $e';
      });
    }
  }

  void _navigateToEditService([Map<String, dynamic>? serviceData]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditServiceScreen(
          token: widget.token,
          serviceData: serviceData,
          isProvider: _userProfile?.isProvider ?? false,
          providerId: widget.userId,
        ),
      ),
    );

    if (result == true) {
      await _fetchServices();
    }
  }

  void _navigateToCreateAppointment(Map<String, dynamic> service) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateAppointmentScreen(
          token: widget.token,
          serviceId: service['id'].toString(),
        ),
      ),
    );

    if (result == true) {
      await _fetchAppointments();
      _tabController.animateTo(1); // Mover a la pestaña de reservas
    }
  }

  Future<void> _confirmAppointment(String appointmentId) async {
    try {
      await ApiService.confirmAppointment(widget.token, appointmentId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita aprobada exitosamente')),
      );
      await _fetchAppointments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al aprobar cita: $e')),
      );
    }
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      await ApiService.cancelAppointment(widget.token, appointmentId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita cancelada exitosamente')),
      );
      await _fetchAppointments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cancelar cita: $e')),
      );
    }
  }

  Future<void> _logout() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
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
      appBar: AppBar(
        title: const Text('Servicios Disponibles'),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFC9B037),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFC9B037),
          labelColor: const Color(0xFFC9B037),
          unselectedLabelColor: Colors.white,
          tabs: [
            const Tab(text: 'SERVICIOS'),
            Tab(
              text: _userProfile?.isProvider ?? false
                  ? 'RESERVAS'
                  : 'MIS RESERVAS',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9B037)))
          : _errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage),
            ElevatedButton(
              onPressed: _loadUserAndServices,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      )
          : _userProfile == null
          ? const Center(child: Text('No se pudo cargar el perfil del usuario'))
          : _buildTabBarView(),
      floatingActionButton: _userProfile?.isProvider ?? false
          ? FloatingActionButton(
        onPressed: () => _navigateToEditService(),
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFFC9B037),
      )
          : null,
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildServiceList(),
        _userProfile?.isProvider ?? false
            ? _buildProviderAppointmentsList()
            : _buildClientAppointmentsList(),
      ],
    );
  }

  Widget _buildServiceList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            _userProfile?.isProvider ?? false
                ? 'Mis Servicios'
                : 'Nuestros Servicios',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _services.isEmpty
                ? Center(
              child: Text(
                _userProfile?.isProvider ?? false
                    ? 'No tienes servicios creados'
                    : 'No hay servicios disponibles',
                style: const TextStyle(fontSize: 18),
              ),
            )
                : ListView.builder(
              itemCount: _services.length,
              itemBuilder: (context, index) {
                final service = _services[index];
                return ServiceCard(
                  name: service['name'] ?? 'Servicio',
                  description: service['description'] ?? '',
                  price: service['price']?.toString() ?? '0',
                  isRefundable: service['is_refundable'] ?? false,
                  isProvider: _userProfile?.isProvider ?? false,
                  onPressed: () {
                    if (!(_userProfile?.isProvider ?? false)) {
                      _navigateToCreateAppointment(service);
                    }
                  },
                  onEdit: _userProfile?.isProvider ?? false
                      ? () => _navigateToEditService(service)
                      : null,
                  onDelete: _userProfile?.isProvider ?? false
                      ? () => _deleteService(service['id'].toString())
                      : null,
                );
              },
            )
          ),
        ],
      ),
    );
  }

  Widget _buildProviderAppointmentsList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Reservas de Clientes',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _appointments.isEmpty
                ? const Center(
              child: Text(
                'No hay reservas pendientes',
                style: TextStyle(fontSize: 18),
              ),
            )
                : RefreshIndicator(
              onRefresh: _fetchAppointments,
              color: const Color(0xFFC9B037),
              child: ListView.builder(
                itemCount: _appointments.length,
                itemBuilder: (context, index) {
                  final appointment = _appointments[index];
                  final profile = appointment['profile'] ?? {};
                  final user = profile['user'] ?? {};
                  final fullName = user['full_name'] ?? 'Cliente no disponible';
                  final service = appointment['service'] ?? {};
                  final serviceName = service['name'] ?? 'Servicio no disponible';
                  final price = service['price']?.toDouble() ?? 0.0;
                  final startsAt = appointment['startsAt'] != null
                      ? DateTime.parse(appointment['startsAt'])
                      : null;

                  final status = _determinarEstado(appointment);
                  return AppointmentCard(
                    appointmentId: appointment['id']?.toString() ?? 'N/A',
                    fullName: fullName,
                    status: status,
                    isProviderView: true,
                    startsAt: startsAt,
                    serviceName: serviceName,
                    price: price,
                    onApprove: status == 'PENDIENTE'
                        ? () => _confirmAppointment(appointment['id'].toString())
                        : null,
                    onCancel: status == 'PENDIENTE'
                        ? () => _cancelAppointment(appointment['id'].toString())
                        : null,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _determinarEstado(Map<String, dynamic> appointment) {
    final confirmedAt = appointment['confirmedAt'];

    if (confirmedAt == null) {
      return 'PENDIENTE';
    }

    // Validación para fecha mágica (cancelada)
    if (confirmedAt.toString().startsWith('1970-01-01')) {
      return 'CANCELADA';
    }

    // Si tiene fecha pero no es la mágica
    return 'APROBADA';
  }

  Widget _buildClientAppointmentsList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Mis Citas',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _appointments.isEmpty
                ? const Center(
              child: Text(
                'No tienes citas programadas',
                style: TextStyle(fontSize: 18),
              ),
            )
                : ListView.builder(
              itemCount: _appointments.length,
              itemBuilder: (context, index) {
                final appointment = _appointments[index];
                final profile = appointment['profile'] ?? {};
                final user = profile['user'] ?? {};
                final fullName = user['full_name'] ?? 'Proveedor no disponible';
                final service = appointment['service'] ?? {};
                final serviceName = service['name'] ?? 'Servicio no disponible';
                final price = service['price']?.toDouble() ?? 0.0;
                final startsAt = appointment['startsAt'] != null
                    ? DateTime.parse(appointment['startsAt'])
                    : null;

                final status = _determinarEstado(appointment);
                return AppointmentCard(
                  appointmentId: appointment['id']?.toString() ?? 'N/A',
                  fullName: fullName,
                  status: status,
                  isProviderView: false,
                  startsAt: startsAt,
                  serviceName: serviceName,
                  price: price,
                  onViewDetails: () => _showAppointmentDetails(appointment),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    final profile = appointment['profile'] ?? {};
    final user = profile['user'] ?? {};
    final service = appointment['service'] ?? {};
    final startsAt = appointment['startsAt'] != null
        ? DateTime.parse(appointment['startsAt'])
        : null;
    final confirmedAt = appointment['confirmedAt'] != null
        ? DateTime.parse(appointment['confirmedAt'])
        : null;
    final createdAt = appointment['createdAt'] != null
        ? DateTime.parse(appointment['createdAt'])
        : null;
    final status = _determinarEstado(appointment);
    final statusColor = _getStatusColor(status);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    'Detalles de la Cita',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sección de estado
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusColor,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        color: statusColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Estado: $status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Información básica
                _buildDetailRow('ID de Cita', appointment['id']?.toString() ?? 'N/A'),
                _buildDetailRow('Servicio', service['name'] ?? 'No disponible'),
                _buildDetailRow('Precio',
                    service['price'] != null ? '\$${service['price'].toStringAsFixed(2)}' : 'No disponible'),

                if (startsAt != null)
                  _buildDetailRow(
                    'Fecha y Hora',
                    DateFormat('EEEE, d MMMM y - hh:mm a', 'es_ES').format(startsAt),
                  ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // Información del proveedor
                const Text(
                  'Información del Proveedor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Nombre', user['full_name'] ?? 'No disponible'),
                _buildDetailRow('Email', user['email'] ?? 'No disponible'),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // Información adicional
                const Text(
                  'Detalles Adicionales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Fecha de Creación',
                  createdAt != null
                      ? DateFormat('dd/MM/yyyy - hh:mm a').format(createdAt)
                      : 'No disponible',
                ),

                if (confirmedAt != null && status == 'APROBADA')
                  _buildDetailRow(
                    'Fecha de Confirmación',
                    DateFormat('dd/MM/yyyy - hh:mm a').format(confirmedAt),
                  ),

                if (appointment['invoice'] != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Método de Pago',
                    appointment['invoice']['paymentMethod'] ?? 'No disponible',
                  ),
                  if (appointment['invoice']['transactionId'] != null)
                    _buildDetailRow(
                      'ID de Transacción',
                      appointment['invoice']['transactionId'],
                    ),
                ],

                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'APROBADA':
        return Icons.check_circle;
      case 'CANCELADA':
        return Icons.cancel;
      case 'PENDIENTE':
        return Icons.access_time;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'APROBADA':
        return Colors.green;
      case 'CANCELADA':
        return Colors.red;
      case 'PENDIENTE':
        return const Color(0xFFC9B037);
      default:
        return Colors.grey;
    }
  }

  Future<void> _deleteService(String serviceId) async {
    try {
      await ApiService.deleteService(widget.token, serviceId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Servicio eliminado correctamente')),
      );
      await _fetchServices();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar servicio: $e')),
      );
    }
  }
}
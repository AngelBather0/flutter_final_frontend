import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final String appointmentId;
  final String fullName;
  final String status;
  final bool isProviderView;
  final DateTime? startsAt;
  final String? serviceName;
  final double? price;
  final VoidCallback? onApprove;
  final VoidCallback? onCancel;
  final VoidCallback? onViewDetails;

  const AppointmentCard({
    super.key,
    required this.appointmentId,
    required this.fullName,
    required this.status,
    required this.isProviderView,
    this.startsAt,
    this.serviceName,
    this.price,
    this.onApprove,
    this.onCancel,
    this.onViewDetails,
  });

  Color _getStatusColor() {
    switch (status) {
      case 'APROBADA':
        return Colors.green;
      case 'CANCELADA':
        return Colors.red;
      case 'PENDIENTE':
        return const Color(0xFFC9B037); // Dorado
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _getStatusColor().withOpacity(0.3),
          width: 1.5,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: !isProviderView ? onViewDetails : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Cita #$appointmentId',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.person, fullName),
              if (serviceName != null)
                _buildDetailRow(Icons.work_outline, serviceName!),
              if (startsAt != null)
                _buildDetailRow(
                  Icons.calendar_today,
                  DateFormat('dd/MM/yyyy - hh:mm a').format(startsAt!),
                ),
              if (price != null)
                _buildDetailRow(
                  Icons.attach_money,
                  'Precio: \$${price!.toStringAsFixed(2)}',
                ),
              const SizedBox(height: 16),

              // Botones correctos según el rol
              if (isProviderView)
                _buildProviderButtons(context)
              else
                _buildClientButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Botones para el proveedor (Aprobar / Cancelar)
  Widget _buildProviderButtons(BuildContext context) {
    if (!isProviderView) return const SizedBox.shrink(); // Asegura que solo el provider vea los botones

    final showApprove = onApprove != null && status == 'PENDIENTE';
    final showCancel = onCancel != null && status != 'CANCELADA';

    if (!showApprove && !showCancel) return const SizedBox.shrink();

    return Row(
      children: [
        if (showApprove)
          Expanded(
            child: _buildActionButton(
              context,
              'APROBAR',
              Colors.green,
              onApprove,
            ),
          ),
        if (showApprove && showCancel)
          const SizedBox(width: 12),
        if (showCancel)
          Expanded(
            child: _buildActionButton(
              context,
              'CANCELAR',
              Colors.red,
              onCancel,
            ),
          ),
      ],
    );
  }

  /// ✅ Botón para clientes ("Ver Detalles")
  Widget _buildClientButton(BuildContext context) {
    if (isProviderView || onViewDetails == null) return const SizedBox.shrink();

    final buttonColor = _getStatusColor(); // Usamos el mismo color del estado

    return Center(
      child: _buildActionButton(
        context,
        'VER DETALLES',
        buttonColor, // Color dinámico según estado
        onViewDetails,
        fullWidth: true,
      ),
    );
  }

  /// 🛠 Función para construir los botones de acción
  Widget _buildActionButton(
      BuildContext context,
      String text,
      Color color,
      VoidCallback? onPressed, {
        bool fullWidth = false,
      }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
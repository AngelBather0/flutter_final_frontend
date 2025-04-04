import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditServiceScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic>? serviceData;
  final bool isProvider;
  final String providerId;

  const EditServiceScreen({
    super.key,
    required this.token,
    this.serviceData,
    required this.isProvider,
    required this.providerId,
  });

  @override
  _EditServiceScreenState createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isRefundable = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.serviceData != null) {
      _nameController.text = widget.serviceData!['name'] ?? '';
      _priceController.text = widget.serviceData!['price']?.toString() ?? '';
      _isRefundable = widget.serviceData!['is_refundable'] ?? false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    final price = int.tryParse(_priceController.text);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un precio válido')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.serviceData == null) {
        await ApiService.createService(
          widget.token,
          _nameController.text,
          _isRefundable,
          price,
          widget.providerId,
        );
      } else {
        await ApiService.updateService(
          widget.token,
          widget.serviceData!['id'].toString(),
          _nameController.text,
          _isRefundable,
          price,
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serviceData == null ? 'Crear Servicio' : 'Editar Servicio'),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFC9B037),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Servicio',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un precio';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Ingrese un número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Reembolsable'),
                  value: _isRefundable,
                  onChanged: (value) {
                    setState(() {
                      _isRefundable = value;
                    });
                  },
                  activeColor: const Color(0xFFC9B037),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9B037),
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text('GUARDAR', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
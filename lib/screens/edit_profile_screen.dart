import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/api_client.dart';
import '../theme/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.usuario,
  });

  final UserProfile usuario;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreController;
  late final TextEditingController _apellidoController;
  late final TextEditingController _fechaController;
  late final TextEditingController _dniController;

  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _nombreController = TextEditingController(text: widget.usuario.nombre);
    _apellidoController = TextEditingController(text: widget.usuario.apellido);
    _dniController = TextEditingController(text: widget.usuario.dni);

    final partes = widget.usuario.fechaNacimiento.split('-');

    final fechaFormateada = partes.length == 3
        ? '${partes[2]}/${partes[1]}/${partes[0]}'
        : widget.usuario.fechaNacimiento;

    _fechaController = TextEditingController(text: fechaFormateada);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _fechaController.dispose();
    _dniController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.indigo[700]!, width: 2),
      ),
    );
  }

  String? _requerido(String? value) {
    if (value == null || value.trim().isEmpty) return 'Requerido';

    return null;
  }

  String? _validarDni(String? value) {
    final numeros = value?.replaceAll(RegExp(r'\D'), '') ?? '';

    if (numeros.length < 7 || numeros.length > 8) {
      return 'Ingrese un DNI válido';
    }

    return null;
  }

  Future<void> _seleccionarFecha() async {
    final partes = _fechaController.text.split('/');

    final fechaInicial = partes.length == 3
        ? DateTime(
            int.parse(partes[2]),
            int.parse(partes[1]),
            int.parse(partes[0]),
          )
        : DateTime(DateTime.now().year - 18);

    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (fecha == null) return;

    setState(() {
      _fechaController.text =
          '${fecha.day.toString().padLeft(2, '0')}/'
          '${fecha.month.toString().padLeft(2, '0')}/'
          '${fecha.year}';
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      final perfilActualizado = await ApiClient.actualizarMiPerfil(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        fechaNacimiento: _fechaController.text,
        dni: _dniController.text.trim(),
      );

      if (!mounted) return;

      Navigator.of(context).pop(perfilActualizado);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _guardando = false;
        _error = 'No se pudo actualizar el perfil.';
      });
    }
  }

  Widget _label(String texto) {
    return Text(
      texto,
      style: TextStyle(
        color: Colors.grey[700],
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.indigo[400],
        foregroundColor: Colors.black,
        title: const Text('Editar perfil'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _label('Nombre'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nombreController,
                decoration: _decoration('Nombre'),
                validator: _requerido,
              ),
              const SizedBox(height: 16),
              _label('Apellido'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _apellidoController,
                decoration: _decoration('Apellido'),
                validator: _requerido,
              ),
              const SizedBox(height: 16),
              _label('Correo electrónico'),
              const SizedBox(height: 6),
              TextFormField(
                initialValue: widget.usuario.email,
                readOnly: true,
                decoration: _decoration('Correo electrónico'),
              ),
              const SizedBox(height: 16),
              _label('Fecha de nacimiento'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _fechaController,
                readOnly: true,
                onTap: _seleccionarFecha,
                decoration: _decoration('DD/MM/AAAA'),
                validator: _requerido,
              ),
              const SizedBox(height: 16),
              _label('Documento (DNI)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _dniController,
                keyboardType: TextInputType.number,
                decoration: _decoration('12.345.678'),
                validator: _validarDni,
              ),
              const SizedBox(height: 24),
              if (_error != null) ...[
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.indigo[400],
                    foregroundColor: Colors.black,
                  ),
                  onPressed: _guardando ? null : _guardar,
                  child: _guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text('Guardar cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
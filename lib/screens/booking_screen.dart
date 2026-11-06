import 'package:flutter/material.dart';

import '../models/cancha.dart';
import '../models/sede.dart';
import '../theme/app_colors.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.cancha, required this.sede});

  final Cancha cancha;
  final Sede sede;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late final List<DateTime> _dias;
  late DateTime _fechaSeleccionada;

  int? _horaInicio;
  int? _horaFin;

  @override
  void initState() {
    super.initState();

    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

    _dias = [
      for (int indice = 0; indice < 14; indice++)
        hoy.add(Duration(days: indice)),
    ];

    _fechaSeleccionada = _dias.first;
  }

  List<int> get _horariosDisponibles {
    // Más adelante estos horarios los traerá la API.
    // Por ahora respetan el horario de cada sede.
    final apertura = int.parse(widget.sede.horaApertura.split(':').first);
    final cierre = int.parse(widget.sede.horaCierre.split(':').first);

    return [for (int hora = apertura; hora < cierre; hora++) hora];
  }

  String _formatearHora(int hora) {
    return '${hora.toString().padLeft(2, '0')}:00';
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  String _diaSemana(DateTime fecha) {
    const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return dias[fecha.weekday - 1];
  }

  void _seleccionarHorario(int hora) {
    setState(() {
      // Primer toque: selecciona una hora de inicio.
      if (_horaInicio == null) {
        _horaInicio = hora;
        _horaFin = hora + 1;
        return;
      }

      // Tocar el mismo horario lo deselecciona.
      if (_horaInicio == hora && _horaFin == hora + 1) {
        _horaInicio = null;
        _horaFin = null;
        return;
      }

      // Si se toca un horario posterior, amplía la reserva.
      if (hora >= _horaFin!) {
        _horaFin = hora + 1;
        return;
      }

      // Si se toca uno anterior, empieza una selección nueva.
      _horaInicio = hora;
      _horaFin = hora + 1;
    });
  }

  void _confirmarReserva() {
    if (_horaInicio == null || _horaFin == null) return;

    final cantidadHoras = _horaFin! - _horaInicio!;
    final total = widget.cancha.precioPorHora * cantidadHoras;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reserva confirmada'),
          content: Text(
            '${widget.cancha.nombre}\n'
            '${widget.sede.nombre}\n'
            '${_formatearFecha(_fechaSeleccionada)}\n'
            '${_formatearHora(_horaInicio!)} a '
            '${_formatearHora(_horaFin!)}\n\n'
            'Total: \$$total',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cantidadHoras = _horaInicio == null ? 0 : _horaFin! - _horaInicio!;
    final total = widget.cancha.precioPorHora * cantidadHoras;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.indigo[400],
        foregroundColor: Colors.black,
        title: const Text('Reservar cancha'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              widget.cancha.nombre,
              style: TextStyle(
                color: Colors.grey[850],
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.sede.nombre} · \$${widget.cancha.precioPorHora}/h',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            const Text(
              'Elegí una fecha',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _dias.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final fecha = _dias[index];
                  final seleccionada = fecha == _fechaSeleccionada;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _fechaSeleccionada = fecha;
                        _horaInicio = null;
                        _horaFin = null;
                      });
                    },
                    child: Container(
                      width: 54,
                      decoration: BoxDecoration(
                        color: seleccionada
                            ? AppColors.indigo[400]
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[700]!),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_diaSemana(fecha)),
                          Text(
                            '${fecha.day}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Elegí horario',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              'Tocá una hora de inicio. Podés tocar otra posterior para reservar más tiempo.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final hora in _horariosDisponibles)
                  ChoiceChip(
                    label: Text(_formatearHora(hora)),
                    selected:
                        _horaInicio != null &&
                        hora >= _horaInicio! &&
                        hora < _horaFin!,
                    selectedColor: AppColors.indigo[400],
                    backgroundColor: AppColors.surface,
                    side: BorderSide(color: Colors.grey[700]!),
                    onSelected: (_) => _seleccionarHorario(hora),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.indigo[400],
                  foregroundColor: Colors.black,
                ),
                onPressed: _horaInicio == null ? null : _confirmarReserva,
                child: Text(
                  _horaInicio == null
                      ? 'Elegí un horario'
                      : 'Reservar '
                            '${_formatearHora(_horaInicio!)} - '
                            '${_formatearHora(_horaFin!)} · \$$total',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

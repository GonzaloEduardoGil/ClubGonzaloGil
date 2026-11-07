import 'package:flutter/material.dart';

import '../models/cancha.dart';
import '../models/sede.dart';
import '../models/slot.dart';
import '../services/api_client.dart';
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
  late Future<List<Slot>> _slotsFuture;

  int? _horaInicio;
  int? _horaFin;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

    _dias = [
      for (int indice = 0; indice < 14; indice++)
        hoy.add(Duration(days: indice)),
    ];

    _seleccionarDia(_dias.first);
  }

  void _seleccionarDia(DateTime fecha) {
    _fechaSeleccionada = fecha;
    _horaInicio = null;
    _horaFin = null;
    _error = null;

    _slotsFuture = ApiClient.obtenerDisponibilidad(
      canchaId: widget.cancha.id,
      fecha: fecha,
    );
  }

  int _horaNumerica(Slot slot) {
    return int.parse(slot.hora.split(':').first);
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

  void _seleccionarHorario(List<Slot> slots, Slot slot) {
    final hora = _horaNumerica(slot);

    if (_horaInicio == null) {
      _horaInicio = hora;
      _horaFin = hora + 1;
      return;
    }

    if (_horaInicio == hora && _horaFin == hora + 1) {
      _horaInicio = null;
      _horaFin = null;
      return;
    }

    if (hora >= _horaFin!) {
      final todosDisponibles = slots
          .where(
            (slotActual) =>
                _horaNumerica(slotActual) >= _horaInicio! &&
                _horaNumerica(slotActual) <= hora,
          )
          .every((slotActual) => slotActual.disponible);

      if (todosDisponibles) {
        _horaFin = hora + 1;
        return;
      }
    }

    _horaInicio = hora;
    _horaFin = hora + 1;
  }

  Future<void> _confirmarReserva() async {
    if (_horaInicio == null || _horaFin == null) return;

    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      await ApiClient.crearReserva(
        canchaId: widget.cancha.id,
        fecha: _fechaSeleccionada,
        horaInicio: _formatearHora(_horaInicio!),
        horaFin: _formatearHora(_horaFin!),
      );

      if (!mounted) return;

      final mensaje =
          'Reserva confirmada para ${_formatearFecha(_fechaSeleccionada)} '
          'de ${_formatearHora(_horaInicio!)} '
          'a ${_formatearHora(_horaFin!)}.';

      final messenger = ScaffoldMessenger.of(context);

      Navigator.of(context).pop();

      messenger.showSnackBar(SnackBar(content: Text(mensaje)));
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _guardando = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
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
                    onTap: _guardando
                        ? null
                        : () {
                            setState(() {
                              _seleccionarDia(fecha);
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
              'Tocá una hora de inicio. Luego podés elegir otra posterior '
              'para reservar más tiempo.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Slot>>(
              future: _slotsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _seleccionarDia(_fechaSeleccionada);
                        });
                      },
                      child: const Text('Reintentar'),
                    ),
                  );
                }

                final slots = snapshot.data ?? [];
                final hayDisponibles = slots.any((slot) => slot.disponible);

                if (!hayDisponibles) {
                  return Text(
                    'No hay horarios disponibles para esta fecha.',
                    style: TextStyle(color: Colors.grey[600]),
                  );
                }

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final slot in slots)
                      ChoiceChip(
                        label: Text(slot.hora),
                        selected:
                            _horaInicio != null &&
                            _horaNumerica(slot) >= _horaInicio! &&
                            _horaNumerica(slot) < _horaFin!,
                        selectedColor: AppColors.indigo[400],
                        backgroundColor: AppColors.surface,
                        side: BorderSide(color: Colors.grey[700]!),
                        onSelected: slot.disponible && !_guardando
                            ? (_) {
                                setState(() {
                                  _seleccionarHorario(slots, slot);
                                });
                              }
                            : null,
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            if (_error != null) ...[
              Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
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
                onPressed: _horaInicio == null || _guardando
                    ? null
                    : _confirmarReserva,
                child: _guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Text(
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

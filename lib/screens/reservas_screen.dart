import 'package:flutter/material.dart';

import '../models/reserva.dart';
import '../services/api_client.dart';
import '../theme/app_colors.dart';

class ReservasScreen extends StatefulWidget {
  const ReservasScreen({super.key});

  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  late Future<List<Reserva>> _reservasFuture;
  bool _verHistorial = false;

  @override
  void initState() {
    super.initState();
    _reservasFuture = ApiClient.obtenerReservas();
  }

  void _recargar() {
    setState(() {
      _reservasFuture = ApiClient.obtenerReservas();
    });
  }

  Future<void> _cancelarReserva(Reserva reserva) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar reserva'),
          content: Text('¿Querés cancelar la reserva de ${reserva.cancha}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Volver'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Cancelar reserva'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    try {
      await ApiClient.cancelarReserva(reserva.id);

      if (!mounted) return;

      _recargar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La reserva fue cancelada correctamente.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Reservas',
                  style: TextStyle(
                    color: Colors.grey[850],
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _recargar,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Actualizar',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Próximas'),
                  selected: !_verHistorial,
                  selectedColor: AppColors.indigo[400],
                  onSelected: (_) {
                    setState(() {
                      _verHistorial = false;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Historial'),
                  selected: _verHistorial,
                  selectedColor: AppColors.indigo[400],
                  onSelected: (_) {
                    setState(() {
                      _verHistorial = true;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Reserva>>(
                future: _reservasFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: OutlinedButton(
                        onPressed: _recargar,
                        child: const Text('Reintentar'),
                      ),
                    );
                  }

                  final reservas = snapshot.data ?? [];

                  final filtradas = _verHistorial
                      ? reservas.where((reserva) => !reserva.esProxima).toList()
                      : reservas.where((reserva) => reserva.esProxima).toList();

                  if (filtradas.isEmpty) {
                    return Center(
                      child: Text(
                        _verHistorial
                            ? 'Todavía no tenés reservas anteriores.'
                            : 'No tenés reservas próximas.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filtradas.length,
                    itemBuilder: (context, index) {
                      final reserva = filtradas[index];

                      return _ReservaCard(
                        reserva: reserva,
                        onCancelar: reserva.esProxima
                            ? () => _cancelarReserva(reserva)
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReservaCard extends StatelessWidget {
  const _ReservaCard({required this.reserva, required this.onCancelar});

  final Reserva reserva;
  final VoidCallback? onCancelar;

  @override
  Widget build(BuildContext context) {
    final cancelada = reserva.estado == 'cancelada';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    reserva.cancha,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cancelada
                        ? Colors.red.shade100
                        : AppColors.indigo[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    reserva.estado.toUpperCase(),
                    style: TextStyle(
                      color: cancelada ? Colors.red.shade900 : Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(reserva.sede),
            const SizedBox(height: 4),
            Text('${reserva.fechaFormateada} · ${reserva.horario}'),
            if (onCancelar != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onCancelar,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancelar reserva'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

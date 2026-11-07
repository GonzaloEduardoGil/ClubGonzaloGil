import 'package:flutter/material.dart';

import '../models/cancha_con_sede.dart';
import '../services/api_client.dart';
import '../theme/app_colors.dart';
import 'booking_screen.dart';

class CanchasScreen extends StatefulWidget {
  const CanchasScreen({super.key});

  @override
  State<CanchasScreen> createState() => _CanchasScreenState();
}

class _CanchasScreenState extends State<CanchasScreen> {
  late Future<List<CanchaConSede>> _canchasFuture;
  String _filtroSeleccionado = 'Todos';

  @override
  void initState() {
    super.initState();
    _canchasFuture = ApiClient.obtenerCanchas();
  }

  void _reintentar() {
    setState(() {
      _canchasFuture = ApiClient.obtenerCanchas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Canchas',
              style: TextStyle(
                color: Colors.grey[850],
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Elegí una cancha para consultar horarios',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<CanchaConSede>>(
                future: _canchasFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: OutlinedButton(
                        onPressed: _reintentar,
                        child: const Text('Reintentar'),
                      ),
                    );
                  }

                  final canchas = snapshot.data ?? [];

                  final deportes = [
                    'Todos',
                    ...canchas
                        .map((canchaConSede) => canchaConSede.cancha.deporte)
                        .toSet(),
                  ];

                  final canchasFiltradas = _filtroSeleccionado == 'Todos'
                      ? canchas
                      : canchas
                          .where(
                            (canchaConSede) =>
                                canchaConSede.cancha.deporte ==
                                _filtroSeleccionado,
                          )
                          .toList();

                  return ListView(
                    children: [
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: deportes.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final deporte = deportes[index];
                            final seleccionado =
                                deporte == _filtroSeleccionado;

                            return ChoiceChip(
                              label: Text(deporte),
                              selected: seleccionado,
                              selectedColor: AppColors.indigo[400],
                              backgroundColor: AppColors.surface,
                              checkmarkColor: Colors.black,
                              labelStyle: TextStyle(
                                color: seleccionado
                                    ? Colors.black
                                    : Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                              side: BorderSide(
                                color: Colors.grey[700]!,
                              ),
                              onSelected: (_) {
                                setState(() {
                                  _filtroSeleccionado = deporte;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      for (final canchaConSede in canchasFiltradas)
                        _CanchaCard(canchaConSede: canchaConSede),
                    ],
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

class _CanchaCard extends StatelessWidget {
  const _CanchaCard({
    required this.canchaConSede,
  });

  final CanchaConSede canchaConSede;

  @override
  Widget build(BuildContext context) {
    final cancha = canchaConSede.cancha;
    final sede = canchaConSede.sede;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cancha.nombre,
            style: TextStyle(
              color: Colors.grey[850],
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${sede.nombre} · ${sede.direccion}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          if (cancha.tipo != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Text(
                cancha.tipo!,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                '\$${cancha.precioPorHora}/h',
                style: TextStyle(
                  color: Colors.grey[850],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.indigo[400],
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookingScreen(
                        cancha: cancha,
                        sede: sede,
                      ),
                    ),
                  );
                },
                child: const Text('RESERVAR'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
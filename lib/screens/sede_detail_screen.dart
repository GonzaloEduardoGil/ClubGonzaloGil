import 'package:flutter/material.dart';

import '../models/cancha.dart';
import '../models/sede.dart';
import '../services/api_client.dart';
import '../theme/app_colors.dart';
import 'booking_screen.dart';

String _imagenParaSede(String nombre) {
  switch (nombre) {
    case 'Sede Norte':
      return 'assets/images/sedes/sede_norte.jpg';
    case 'Sede Centro':
      return 'assets/images/sedes/sede_centro.jpg';
    case 'Sede Sur':
      return 'assets/images/sedes/sede_sur.jpg';
    case 'Sede Este':
      return 'assets/images/sedes/sede_este.jpg';
    default:
      return 'assets/images/sedes/sede_norte.jpg';
  }
}

class SedeDetailScreen extends StatefulWidget {
  const SedeDetailScreen({super.key, required this.sede});

  final Sede sede;

  @override
  State<SedeDetailScreen> createState() => _SedeDetailScreenState();
}

class _SedeDetailScreenState extends State<SedeDetailScreen> {
  late Future<Sede> _sedeFuture;
  String _filtroSeleccionado = 'Todos';

  @override
  void initState() {
    super.initState();
    _sedeFuture = ApiClient.obtenerSede(widget.sede.id);
  }

  void _reintentar() {
    setState(() {
      _sedeFuture = ApiClient.obtenerSede(widget.sede.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Sede>(
      future: _sedeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Sede')),
            body: Center(
              child: OutlinedButton(
                onPressed: _reintentar,
                child: const Text('Reintentar'),
              ),
            ),
          );
        }

        return _buildScreen(snapshot.data!);
      },
    );
  }

  Widget _buildScreen(Sede sede) {
    final deportes = [
      'Todos',
      ...sede.canchas.map((cancha) => cancha.deporte).toSet(),
    ];

    final canchasFiltradas = _filtroSeleccionado == 'Todos'
        ? sede.canchas
        : sede.canchas
              .where((cancha) => cancha.deporte == _filtroSeleccionado)
              .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 230,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_imagenParaSede(sede.nombre)),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 16, 20, 24),
                color: const Color.fromRGBO(0, 0, 0, 0.42),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    const Text(
                      'SEDE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sede.nombre.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      sede.direccion,
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Abierto de ${sede.horario}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: deportes.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final deporte = deportes[index];
                        final seleccionado = deporte == _filtroSeleccionado;

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
                          side: BorderSide(color: Colors.grey[700]!),
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
                  for (final cancha in canchasFiltradas)
                    _CanchaCard(cancha: cancha, sede: sede),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CanchaCard extends StatelessWidget {
  const _CanchaCard({required this.cancha, required this.sede});

  final Cancha cancha;
  final Sede sede;

  @override
  Widget build(BuildContext context) {
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
            cancha.nombreMostrado,
            style: TextStyle(
              color: Colors.grey[850],
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (cancha.tipo != null) _Badge(cancha.tipo!),
              for (final item in cancha.caracteristicas) _Badge(item),
            ],
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
                      builder: (_) => BookingScreen(cancha: cancha, sede: sede),
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

class _Badge extends StatelessWidget {
  const _Badge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'sedes_screen.dart';
import '../models/user_profile.dart';
import 'profile_screen.dart';
import 'reservas_screen.dart';
import 'canchas_screen.dart';
import '../services/push_service.dart';
import '../models/reserva.dart';
import '../services/api_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.usuario});

  final UserProfile usuario;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _goToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late UserProfile _usuario;

  @override
  void initState() {
    super.initState();
    _usuario = widget.usuario;
    PushService.inicializar();
  }

  void _actualizarPerfil(UserProfile usuarioActualizado) {
    setState(() {
      _usuario = usuarioActualizado;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeContent(nombre: _usuario.nombre, onReservar: () => _goToTab(2)),
      const SedesScreen(),
      const CanchasScreen(),
      const ReservasScreen(),
      ProfileScreen(usuario: _usuario, onProfileUpdated: _actualizarPerfil),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[700]!, width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: AppColors.indigo[700],
          unselectedItemColor: Colors.grey[500],
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _goToTab,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: 'Sedes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_soccer),
              label: 'Canchas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Reservas',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.nombre, required this.onReservar});
  final String nombre;
  final VoidCallback onReservar;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Reserva>>(
      future: ApiClient.obtenerReservas(),
      builder: (context, snapshot) {
        final proximas =
            (snapshot.data ?? []).where((reserva) => reserva.esProxima).toList()
              ..sort((a, b) {
                final fechaA = DateTime.parse('${a.fecha} ${a.horaInicio}');
                final fechaB = DateTime.parse('${b.fecha} ${b.horaInicio}');
                return fechaA.compareTo(fechaB);
              });

        final proximaReserva = proximas.isEmpty ? null : proximas.first;
        final cargando = snapshot.connectionState != ConnectionState.done;

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                    image: DecorationImage(
                      image: AssetImage('assets/images/portada_inicio.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(0, 0, 0, 0.35),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Hola, $nombre',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 48),
                        const Text(
                          'CLUB GONZALO GIL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'ZONA DEPORTIVA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[700]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.indigo[400],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.event_available,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Próxima reserva',
                                style: TextStyle(
                                  color: AppColors.indigo[900],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cargando
                                    ? 'Buscando reserva...'
                                    : proximaReserva?.canchaMostrada ??
                                          'Sin reservas próximas',
                                style: TextStyle(
                                  color: Colors.grey[850],
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                cargando
                                    ? 'Un momento por favor'
                                    : proximaReserva == null
                                    ? 'Elegí una sede para reservar'
                                    : '${proximaReserva.sede} · '
                                          '${proximaReserva.fechaFormateada} · '
                                          '${proximaReserva.horario}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onReservar,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.indigo[400],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.sports_soccer),
                      label: const Text(
                        'RESERVAR UNA CANCHA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

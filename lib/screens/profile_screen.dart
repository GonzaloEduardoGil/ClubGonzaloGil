import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import 'edit_profile_screen.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.usuario,
    required this.onProfileUpdated,
  });

  final UserProfile usuario;
  final ValueChanged<UserProfile> onProfileUpdated;

  String get _fechaFormateada {
    final partes = usuario.fechaNacimiento.split('-');

    if (partes.length != 3) return usuario.fechaNacimiento;

    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  Future<void> _editarPerfil(BuildContext context) async {
    final actualizado = await Navigator.of(context).push<UserProfile>(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(usuario: usuario),
      ),
    );

    if (actualizado != null) {
      onProfileUpdated(actualizado);
    }
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Seguro que querés cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !context.mounted) return;

    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const WelcomeScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              const Text(
                'Perfil',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _editarPerfil(context),
                icon: const Icon(Icons.edit),
                tooltip: 'Editar perfil',
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Center(
            child: CircleAvatar(
              radius: 42,
              child: Icon(Icons.person, size: 46),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${usuario.nombre} ${usuario.apellido}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 28),
          _ProfileData(
            icon: Icons.email_outlined,
            label: 'Correo electrónico',
            value: usuario.email,
          ),
          _ProfileData(
            icon: Icons.badge_outlined,
            label: 'Documento (DNI)',
            value: usuario.dni,
          ),
          _ProfileData(
            icon: Icons.calendar_today_outlined,
            label: 'Fecha de nacimiento',
            value: _fechaFormateada,
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
              ),
              onPressed: () => _cerrarSesion(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileData extends StatelessWidget {
  const _ProfileData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}
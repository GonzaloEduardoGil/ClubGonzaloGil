import '../models/sede.dart';

// Datos temporales. Más adelante serán reemplazados por GET /sedes.
const sedesDemo = [
  Sede(
    id: 1,
    nombre: 'Sede Norte',
    direccion: 'Av. Libertador 1200',
    horaApertura: '08:00',
    horaCierre: '23:00',
    deportes: ['Fútbol', 'Tenis'],
  ),
  Sede(
    id: 2,
    nombre: 'Sede Centro',
    direccion: 'Calle San Martín 450',
    horaApertura: '07:00',
    horaCierre: '22:00',
    deportes: ['Fútbol', 'Golf'],
  ),
  Sede(
    id: 3,
    nombre: 'Sede Sur',
    direccion: 'Ruta 8 km 24',
    horaApertura: '09:00',
    horaCierre: '21:00',
    deportes: ['Tenis', 'Hockey', 'Golf'],
  ),
  Sede(
    id: 4,
    nombre: 'Sede Este',
    direccion: 'Av. Mitre 780',
    horaApertura: '10:00',
    horaCierre: '23:00',
    deportes: ['Fútbol'],
  ),
];

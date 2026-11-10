# Club Gonzalo Gil

Aplicación móvil para gestionar la reserva de espacios deportivos.

Permite registrarse, iniciar sesión, consultar sedes y canchas, reservar horarios disponibles, cancelar reservas, editar el perfil y recibir notificaciones push.

## Tecnologías

### Aplicación móvil

- Flutter
- Dart
- Firebase Authentication
- Firebase Cloud Messaging
- Flutter Local Notifications

### Backend

- Python
- FastAPI
- SQLAlchemy
- PostgreSQL
- Firebase Admin SDK
- Swagger / OpenAPI

### Despliegue

- API REST: Render
- Base de datos PostgreSQL: Render
- Autenticación y notificaciones: Firebase

## Funcionalidades

- Registro de usuario mediante email y contraseña.
- Inicio y cierre de sesión.
- Recuperación de contraseña mediante email.
- Persistencia de sesión.
- Consulta y edición del perfil.
- Listado de sedes deportivas.
- Consulta y filtro de canchas por deporte.
- Consulta de disponibilidad por fecha y cancha.
- Reserva de turnos en horas completas.
- Validación de horario futuro, duración mínima de una hora y horario de cierre de la sede.
- Prevención de superposición de reservas.
- Listado de reservas próximas e historial.
- Cancelación de reservas.
- Notificación push al confirmar una reserva.
- Recordatorios automáticos 24 horas y una hora antes de la reserva.
- Manejo de errores de conexión, servidor y validaciones.

## Requisitos previos

- Flutter SDK.
- Android Studio con emulador Android.
- Proyecto Firebase configurado.
- Python 3.10 o superior.
- PostgreSQL, solo para desarrollo local.

## Ejecutar la aplicación móvil

Instalar dependencias:

- flutter pub get

## Ejecutar usando la API desplegada en Render

flutter run --dart-define=API_BASE_URL=https://club-gonzalo-gil-api.onrender.com

## Ejecutar contra una API local desde el emulador Android:

flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000

## API desplegada

- API: https://club-gonzalo-gil-api.onrender.com
- Swagger: https://club-gonzalo-gil-api.onrender.com/docs
- Health check: https://club-gonzalo-gil-api.onrender.com/health

## Estructura principal

lib/ <br>
   models/       Modelos usados por Flutter. <br>
   screens/      Pantallas de la aplicación. <br>
   services/     Conexión con API, Firebase y notificaciones. <br>
   theme/        Colores compartidos. <br>
backend/ <br>
    app/ <br>
      routers/    Endpoints de la API. <br>
      models.py   Modelos de PostgreSQL. <br>
      schemas.py  Validación de solicitudes y respuestas. <br>
      notifier.py Recordatorios automáticos. <br>

## Seguridad
### Los secretos no se suben al repositorio:
- backend/.env
- backend/firebase-service-account.json

## La API identifica a cada usuario mediante el ID token emitido por Firebase Authentication.
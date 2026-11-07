# Backend - Club Gonzalo Gil

API REST para la gestión de usuarios, sedes, canchas, reservas y notificaciones push de Club Gonzalo Gil.

## Tecnologías

- Python
- FastAPI
- SQLAlchemy
- PostgreSQL
- Firebase Admin SDK
- Swagger / OpenAPI

## API desplegada

- API: https://club-gonzalo-gil-api.onrender.com
- Swagger: https://club-gonzalo-gil-api.onrender.com/docs
- Health check: https://club-gonzalo-gil-api.onrender.com/health

## Requisitos locales

- Python 3.10 o superior.
- PostgreSQL.
- Proyecto Firebase configurado.
- Archivo privado de cuenta de servicio de Firebase.

## Instalación local

Desde la carpeta `backend`:


- python -m venv .venv

## Activar el entorno virtual en PowerShell:

- .\.venv\Scripts\Activate.ps1

## Instalar dependencias:

- pip install -r requirements.txt

## Variables de entorno locales
### Crear un archivo llamado .env dentro de backend:

- DB_PASSWORD=TU_CONTRASENA_DE_POSTGRESQL

### También se necesita el archivo privado de Firebase:

- firebase-service-account.json
- Ese archivo no se sube a GitHub.

### Antes de iniciar la API, indicar la ubicación de la credencial en PowerShell:

- $env:GOOGLE_APPLICATION_CREDENTIALS = "$PWD\firebase-service-account.json"

## Ejecutar la API

- .\.venv\Scripts\python.exe -m uvicorn app.main:app --reload

### La API queda disponible en:

- http://127.0.0.1:8000

### La documentación Swagger local está en:

- http://127.0.0.1:8000/docs

## Endpoints principales

- | Método | Ruta | Descripción |
- | --- | --- | --- |
- | GET | `/health` | Comprueba que la API está disponible. |
- | GET | `/sedes` | Lista las sedes deportivas. |
- | GET | `/sedes/{sede_id}` | Consulta una sede con sus canchas. |
- | GET | `/canchas` | Lista todas las canchas. |
- | GET | `/canchas/{cancha_id}/disponibilidad` | Consulta horarios disponibles. |
- | POST | `/users/me` | Crea el perfil de un usuario autenticado. |
- | GET | `/users/me` | Consulta el perfil autenticado. |
- | PATCH | `/users/me` | Edita nombre, apellido, fecha de nacimiento y DNI. |
- | POST | `/reservas` | Crea una reserva validando disponibilidad. |
- | GET | `/reservas` | Lista las reservas del usuario autenticado. |
- | PATCH | `/reservas/{reserva_id}/cancelar` | Cancela una reserva. |
- | POST | `/device-tokens` | Registra un dispositivo para notificaciones push. |

## Validaciones de reservas

La API valida que:
- El usuario esté autenticado mediante Firebase.
- La cancha exista.
- El horario sea futuro.
- El inicio y fin sean en horas completas.
- La duración sea de al menos una hora.
- La reserva no supere el horario de cierre de la sede.
- No exista superposición con otra reserva confirmada de la misma cancha.

## Notificaciones

Al crear una reserva, el backend envía una notificación push de confirmación.
El archivo app/notifier.py revisa las reservas confirmadas cada minuto y envía recordatorios:
- Aproximadamente 24 horas antes.
- Aproximadamente una hora antes.
Para evitar avisos duplicados, PostgreSQL guarda las fechas de envío en:
- reminder_24h_sent_at
- reminder_1h_sent_at

## Base de datos

Las tablas principales son:
- users
- sedes
- canchas
- reservas
- device_tokens

Al iniciar una base vacía, FastAPI crea las tablas y carga las sedes y canchas iniciales.

## Despliegue en Render

Render usa estas variables privadas:
- DATABASE_URL
- FIREBASE_SERVICE_ACCOUNT_JSON

No se deben guardar secretos, contraseñas ni claves de Firebase en GitHub.

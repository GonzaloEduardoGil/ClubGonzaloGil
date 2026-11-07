# Modelo de datos - Club Gonzalo Gil

```mermaid
erDiagram
    USERS ||--o{ RESERVAS : realiza
    USERS ||--o{ DEVICE_TOKENS : registra
    SEDES ||--o{ CANCHAS : contiene
    CANCHAS ||--o{ RESERVAS : recibe

    USERS {
        int id PK
        string firebase_uid UK
        string nombre
        string apellido
        string email UK
        date fecha_nacimiento
        string dni UK
    }

    SEDES {
        int id PK
        string nombre UK
        string direccion
        time hora_apertura
        time hora_cierre
    }

    CANCHAS {
        int id PK
        int sede_id FK
        string nombre UK
        string deporte
        string tipo
        decimal precio_por_hora
    }

    RESERVAS {
        int id PK
        int usuario_id FK
        int cancha_id FK
        date fecha
        time hora_inicio
        time hora_fin
        string estado
        datetime creada_en
        datetime reminder_24h_sent_at
        datetime reminder_1h_sent_at
    }

    DEVICE_TOKENS {
        int id PK
        int usuario_id FK
        string token UK
    }
```

## Relaciones

- Un usuario puede realizar muchas reservas.
- Un usuario puede registrar uno o varios dispositivos para recibir notificaciones.
- Una sede puede contener muchas canchas.
- Una cancha pertenece a una sola sede.
- Una cancha puede tener muchas reservas a lo largo del tiempo.
- Una reserva corresponde a un único usuario y a una única cancha.

## Reglas principales

- El correo, DNI y `firebase_uid` son únicos para cada usuario.
- El nombre de una cancha es único.
- El token de notificación pertenece a un único dispositivo registrado.
- Una reserva confirmada bloquea el horario de su cancha.
- Una reserva cancelada se conserva en el historial, pero libera su horario.
- Las columnas de recordatorio evitan enviar la misma notificación más de una vez.
```
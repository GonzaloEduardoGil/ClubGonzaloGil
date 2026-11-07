import asyncio
import logging
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo

from sqlalchemy import select
from sqlalchemy.orm import joinedload

from .db import SessionLocal
from .firebase import enviar_notificacion
from .models import Cancha, DeviceToken, Reserva

logger = logging.getLogger(__name__)

ZONA_HORARIA_CLUB = ZoneInfo("America/Argentina/Buenos_Aires")
INTERVALO_SEGUNDOS = 60
TOLERANCIA = timedelta(minutes=2)


def ahora_del_club() -> datetime:
    return datetime.now(ZONA_HORARIA_CLUB).replace(tzinfo=None)


def esta_en_ventana(
    tiempo_restante: timedelta,
    anticipacion: timedelta,
) -> bool:
    return (
        anticipacion - TOLERANCIA
        <= tiempo_restante
        <= anticipacion + TOLERANCIA
    )


def enviar_recordatorios_pendientes() -> None:
    ahora = ahora_del_club()

    with SessionLocal() as db:
        reservas = db.scalars(
            select(Reserva)
            .where(Reserva.estado == "confirmada")
            .options(
                joinedload(Reserva.cancha).joinedload(Cancha.sede),
            ),
        ).all()

        for reserva in reservas:
            inicio = datetime.combine(
                reserva.fecha,
                reserva.hora_inicio,
            )

            tiempo_restante = inicio - ahora

            recordatorios = [
                (
                    "reminder_24h_sent_at",
                    timedelta(hours=24),
                    "Tenés una reserva mañana",
                ),
                (
                    "reminder_1h_sent_at",
                    timedelta(hours=1),
                    "Tu reserva comienza en una hora",
                ),
            ]

            for campo, anticipacion, titulo in recordatorios:
                if getattr(reserva, campo) is not None:
                    continue

                if not esta_en_ventana(tiempo_restante, anticipacion):
                    continue

                tokens = list(
                    db.scalars(
                        select(DeviceToken.token).where(
                            DeviceToken.usuario_id == reserva.usuario_id,
                        ),
                    ),
                )

                if not tokens:
                    continue

                cuerpo = (
                    f"{reserva.cancha.nombre} - "
                    f"{reserva.cancha.sede.nombre}. "
                    f"{reserva.fecha:%d/%m/%Y} de "
                    f"{reserva.hora_inicio:%H:%M} a "
                    f"{reserva.hora_fin:%H:%M}."
                )

                try:
                    enviar_notificacion(tokens, titulo, cuerpo)

                    setattr(
                        reserva,
                        campo,
                        datetime.now(timezone.utc),
                    )

                    db.commit()
                    logger.info(
                        "Recordatorio %s enviado para la reserva %s",
                        campo,
                        reserva.id,
                        )
                except Exception:
                    logger.exception(
                        "No se pudo enviar el recordatorio de reserva %s",
                        reserva.id,
                    )
                    db.rollback()


async def ejecutar_recordatorios() -> None:
    while True:
        try:
            await asyncio.to_thread(
                enviar_recordatorios_pendientes,
            )
        except Exception:
            logger.exception("Error en el planificador de recordatorios")

        await asyncio.sleep(INTERVALO_SEGUNDOS)
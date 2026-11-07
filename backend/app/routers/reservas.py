from datetime import date, datetime, time

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from ..db import SessionLocal
from ..deps import get_firebase_uid
from ..firebase import enviar_notificacion
from ..models import Cancha, DeviceToken, Reserva, User
from ..schemas import (
    ReservaCreate,
    ReservaDetalleResponse,
    ReservaResponse,
    SlotResponse,
)

router = APIRouter(tags=["Reservas"])


def get_db():
    db = SessionLocal()

    try:
        yield db
    finally:
        db.close()


def es_hora_completa(hora: time) -> bool:
    return hora.minute == 0 and hora.second == 0 and hora.microsecond == 0

def convertir_reserva(reserva: Reserva) -> dict:
    return {
        "id": reserva.id,
        "sede": reserva.cancha.sede.nombre,
        "cancha": reserva.cancha.nombre,
        "fecha": reserva.fecha,
        "hora_inicio": reserva.hora_inicio,
        "hora_fin": reserva.hora_fin,
        "estado": reserva.estado,
    }

@router.get(
    "/canchas/{cancha_id}/disponibilidad",
    response_model=list[SlotResponse],
)
def consultar_disponibilidad(
    cancha_id: int,
    fecha: date,
    db: Session = Depends(get_db),
):
    cancha = db.scalar(
        select(Cancha)
        .where(Cancha.id == cancha_id)
        .options(joinedload(Cancha.sede)),
    )

    if cancha is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Cancha no encontrada.",
        )

    reservas = db.scalars(
        select(Reserva).where(
            Reserva.cancha_id == cancha_id,
            Reserva.fecha == fecha,
            Reserva.estado == "confirmada",
        ),
    ).all()

    apertura = cancha.sede.hora_apertura.hour
    cierre = cancha.sede.hora_cierre.hour
    ahora = datetime.now()

    horarios = []

    for hora in range(apertura, cierre):
        inicio = time(hora, 0)

        ocupada = any(
            reserva.hora_inicio <= inicio < reserva.hora_fin
            for reserva in reservas
        )

        ya_paso = datetime.combine(fecha, inicio) <= ahora

        horarios.append(
            {
                "hora": f"{hora:02d}:00",
                "disponible": not ocupada and not ya_paso,
            },
        )

    return horarios


@router.post(
    "/reservas",
    response_model=ReservaResponse,
    status_code=status.HTTP_201_CREATED,
)
def crear_reserva(
    datos: ReservaCreate,
    firebase_uid: str = Depends(get_firebase_uid),
    db: Session = Depends(get_db),
):
    usuario = db.scalar(
        select(User).where(User.firebase_uid == firebase_uid),
    )

    if usuario is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Perfil de usuario no encontrado.",
        )

    cancha = db.scalar(
        select(Cancha)
        .where(Cancha.id == datos.cancha_id)
        .options(joinedload(Cancha.sede)),
    )

    if cancha is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Cancha no encontrada.",
        )

    if not es_hora_completa(datos.hora_inicio) or not es_hora_completa(
        datos.hora_fin,
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Los horarios deben comenzar y finalizar en horas completas.",
        )

    if datos.hora_fin <= datos.hora_inicio:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La reserva debe durar al menos una hora.",
        )

    if datos.hora_inicio < cancha.sede.hora_apertura:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La reserva comienza antes del horario de apertura.",
        )

    if datos.hora_fin > cancha.sede.hora_cierre:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La reserva finaliza después del horario de cierre.",
        )

    inicio_reserva = datetime.combine(datos.fecha, datos.hora_inicio)

    if inicio_reserva <= datetime.now():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La reserva debe ser para un horario futuro.",
        )

    reserva_superpuesta = db.scalar(
        select(Reserva).where(
            Reserva.cancha_id == cancha.id,
            Reserva.fecha == datos.fecha,
            Reserva.estado == "confirmada",
            Reserva.hora_inicio < datos.hora_fin,
            Reserva.hora_fin > datos.hora_inicio,
        ),
    )

    if reserva_superpuesta is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="La cancha ya está reservada en ese horario.",
        )

    reserva = Reserva(
        usuario_id=usuario.id,
        cancha_id=cancha.id,
        fecha=datos.fecha,
        hora_inicio=datos.hora_inicio,
        hora_fin=datos.hora_fin,
        estado="confirmada",
    )

    db.add(reserva)
    db.commit()
    db.refresh(reserva)

    tokens = list(
        db.scalars(
            select(DeviceToken.token).where(
                DeviceToken.usuario_id == usuario.id,
            ),
        ),
    )

    try:
        enviar_notificacion(
            tokens,
            "Reserva confirmada",
            (
                f"{cancha.nombre} en {cancha.sede.nombre}. "
                f"{datos.fecha:%d/%m/%Y} de "
                f"{datos.hora_inicio:%H:%M} a "
                f"{datos.hora_fin:%H:%M}."
            ),
        )
    except Exception:
        # Una falla de notificación no debe cancelar una reserva válida.
        pass

    return reserva
@router.get(
    "/reservas",
    response_model=list[ReservaDetalleResponse],
)
def listar_mis_reservas(
    firebase_uid: str = Depends(get_firebase_uid),
    db: Session = Depends(get_db),
):
    usuario = db.scalar(
        select(User).where(User.firebase_uid == firebase_uid),
    )

    if usuario is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Perfil de usuario no encontrado.",
        )

    reservas = db.scalars(
        select(Reserva)
        .where(Reserva.usuario_id == usuario.id)
        .options(
            joinedload(Reserva.cancha).joinedload(Cancha.sede),
        )
        .order_by(Reserva.fecha.desc(), Reserva.hora_inicio.desc()),
    ).all()

    return [convertir_reserva(reserva) for reserva in reservas]


@router.patch(
    "/reservas/{reserva_id}/cancelar",
    response_model=ReservaDetalleResponse,
)
def cancelar_reserva(
    reserva_id: int,
    firebase_uid: str = Depends(get_firebase_uid),
    db: Session = Depends(get_db),
):
    usuario = db.scalar(
        select(User).where(User.firebase_uid == firebase_uid),
    )

    if usuario is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Perfil de usuario no encontrado.",
        )

    reserva = db.scalar(
        select(Reserva)
        .where(
            Reserva.id == reserva_id,
            Reserva.usuario_id == usuario.id,
        )
        .options(
            joinedload(Reserva.cancha).joinedload(Cancha.sede),
        ),
    )

    if reserva is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Reserva no encontrada.",
        )

    if reserva.estado == "cancelada":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La reserva ya fue cancelada.",
        )

    reserva.estado = "cancelada"

    db.commit()
    db.refresh(reserva)

    return convertir_reserva(reserva)
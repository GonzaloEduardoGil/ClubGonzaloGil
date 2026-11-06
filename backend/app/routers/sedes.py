from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from ..db import SessionLocal
from ..models import Sede
from ..schemas import SedeDetailResponse, SedeListResponse

router = APIRouter(prefix="/sedes", tags=["Sedes"])


def get_db():
    db = SessionLocal()

    try:
        yield db
    finally:
        db.close()


def convertir_sede(sede: Sede) -> dict:
    deportes = []

    for cancha in sede.canchas:
        if cancha.deporte not in deportes:
            deportes.append(cancha.deporte)

    return {
        "id": sede.id,
        "nombre": sede.nombre,
        "direccion": sede.direccion,
        "hora_apertura": sede.hora_apertura,
        "hora_cierre": sede.hora_cierre,
        "deportes": deportes,
    }


@router.get("", response_model=list[SedeListResponse])
def listar_sedes(db: Session = Depends(get_db)):
    sedes = db.scalars(
        select(Sede)
        .options(selectinload(Sede.canchas))
        .order_by(Sede.id)
    ).all()

    return [convertir_sede(sede) for sede in sedes]


@router.get("/{sede_id}", response_model=SedeDetailResponse)
def obtener_sede(sede_id: int, db: Session = Depends(get_db)):
    sede = db.scalar(
        select(Sede)
        .where(Sede.id == sede_id)
        .options(selectinload(Sede.canchas))
    )

    if sede is None:
        raise HTTPException(status_code=404, detail="Sede no encontrada")

    resultado = convertir_sede(sede)

    resultado["canchas"] = [
        {
            "id": cancha.id,
            "nombre": cancha.nombre,
            "deporte": cancha.deporte,
            "tipo": cancha.tipo,
            "precio_por_hora": float(cancha.precio_por_hora),
        }
        for cancha in sede.canchas
    ]

    return resultado
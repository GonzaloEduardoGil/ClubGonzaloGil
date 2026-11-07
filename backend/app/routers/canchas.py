from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from ..db import SessionLocal
from ..models import Cancha
from ..schemas import CanchaListaResponse

router = APIRouter(prefix="/canchas", tags=["Canchas"])


def get_db():
    db = SessionLocal()

    try:
        yield db
    finally:
        db.close()


@router.get("", response_model=list[CanchaListaResponse])
def listar_canchas(db: Session = Depends(get_db)):
    canchas = db.scalars(
        select(Cancha)
        .options(joinedload(Cancha.sede))
        .order_by(Cancha.id),
    ).all()

    return [
        {
            "id": cancha.id,
            "nombre": cancha.nombre,
            "deporte": cancha.deporte,
            "tipo": cancha.tipo,
            "precio_por_hora": float(cancha.precio_por_hora),
            "sede_id": cancha.sede.id,
            "sede_nombre": cancha.sede.nombre,
            "sede_direccion": cancha.sede.direccion,
            "hora_apertura": cancha.sede.hora_apertura,
            "hora_cierre": cancha.sede.hora_cierre,
        }
        for cancha in canchas
    ]
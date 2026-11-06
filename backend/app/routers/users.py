from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from ..db import SessionLocal
from ..deps import get_firebase_uid
from ..models import User
from ..schemas import UserCreate, UserResponse

router = APIRouter(prefix="/users", tags=["Usuarios"])


def get_db():
    db = SessionLocal()

    try:
        yield db
    finally:
        db.close()


@router.post("/me", response_model=UserResponse)
def crear_o_consultar_perfil(
    datos: UserCreate,
    firebase_uid: str = Depends(get_firebase_uid),
    db: Session = Depends(get_db),
):
    usuario_existente = db.scalar(
        select(User).where(User.firebase_uid == firebase_uid),
    )

    if usuario_existente is not None:
        return usuario_existente

    email_existente = db.scalar(
        select(User).where(User.email == datos.email),
    )

    if email_existente is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Ya existe un perfil con ese correo.",
        )

    usuario = User(
        firebase_uid=firebase_uid,
        nombre=datos.nombre,
        apellido=datos.apellido,
        email=datos.email,
        fecha_nacimiento=datos.fecha_nacimiento,
        dni=datos.dni,
    )

    db.add(usuario)
    db.commit()
    db.refresh(usuario)

    return usuario
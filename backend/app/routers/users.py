from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from ..db import SessionLocal
from ..deps import get_firebase_uid
from ..models import User
from ..schemas import UserCreate, UserResponse, UserUpdate

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
@router.get("/me", response_model=UserResponse)
def obtener_mi_perfil(
    firebase_uid: str = Depends(get_firebase_uid),
    db: Session = Depends(get_db),
):
    usuario = db.scalar(
        select(User).where(User.firebase_uid == firebase_uid),
    )

    if usuario is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Perfil no encontrado.",
        )

    return usuario
@router.patch("/me", response_model=UserResponse)
def editar_mi_perfil(
    datos: UserUpdate,
    firebase_uid: str = Depends(get_firebase_uid),
    db: Session = Depends(get_db),
):
    usuario = db.scalar(
        select(User).where(User.firebase_uid == firebase_uid),
    )

    if usuario is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Perfil no encontrado.",
        )

    dni_existente = db.scalar(
        select(User).where(
            User.dni == datos.dni,
            User.id != usuario.id,
        ),
    )

    if dni_existente is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Ya existe un perfil con ese DNI.",
        )

    usuario.nombre = datos.nombre
    usuario.apellido = datos.apellido
    usuario.fecha_nacimiento = datos.fecha_nacimiento
    usuario.dni = datos.dni

    db.commit()
    db.refresh(usuario)

    return usuario
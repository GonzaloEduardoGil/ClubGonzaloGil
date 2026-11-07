from fastapi import APIRouter, Depends, Response, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from ..db import SessionLocal
from ..deps import get_firebase_uid
from ..models import DeviceToken, User
from ..schemas import DeviceTokenCreate

router = APIRouter(prefix="/device-tokens", tags=["Notificaciones"])


def get_db():
    db = SessionLocal()

    try:
        yield db
    finally:
        db.close()


@router.post("", status_code=status.HTTP_204_NO_CONTENT)
def registrar_token(
    datos: DeviceTokenCreate,
    firebase_uid: str = Depends(get_firebase_uid),
    db: Session = Depends(get_db),
):
    usuario = db.scalar(
        select(User).where(User.firebase_uid == firebase_uid),
    )

    if usuario is None:
        return Response(status_code=status.HTTP_404_NOT_FOUND)

    token_existente = db.scalar(
        select(DeviceToken).where(DeviceToken.token == datos.token),
    )

    if token_existente is None:
        db.add(
            DeviceToken(
                usuario_id=usuario.id,
                token=datos.token,
            ),
        )
    elif token_existente.usuario_id != usuario.id:
        # El mismo teléfono inició sesión con otra cuenta.
        token_existente.usuario_id = usuario.id

    db.commit()

    return Response(status_code=status.HTTP_204_NO_CONTENT)
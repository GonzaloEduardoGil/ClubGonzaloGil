from typing import Any

from fastapi import Header, HTTPException, status

from .firebase import verify_firebase_token


def get_firebase_claims(
    authorization: str | None = Header(default=None),
) -> dict[str, Any]:
    if authorization is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Falta el token de autenticación.",
        )

    esquema, _, token = authorization.partition(" ")

    if esquema.lower() != "bearer" or not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token de autenticación inválido.",
        )

    try:
        return verify_firebase_token(token)
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="No se pudo validar el token de Firebase.",
        )


def get_firebase_uid(
    authorization: str | None = Header(default=None),
) -> str:
    return get_firebase_claims(authorization)["uid"]
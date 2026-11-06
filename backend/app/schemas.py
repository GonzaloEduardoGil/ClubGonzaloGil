from datetime import time

from pydantic import BaseModel

from datetime import date


class CanchaResponse(BaseModel):
    id: int
    nombre: str
    deporte: str
    tipo: str | None
    precio_por_hora: float


class SedeListResponse(BaseModel):
    id: int
    nombre: str
    direccion: str
    hora_apertura: time
    hora_cierre: time
    deportes: list[str]


class SedeDetailResponse(SedeListResponse):
    canchas: list[CanchaResponse]

class UserCreate(BaseModel):
    nombre: str
    apellido: str
    email: str
    fecha_nacimiento: date
    dni: str


class UserResponse(BaseModel):
    id: int
    nombre: str
    apellido: str
    email: str
    fecha_nacimiento: date
    dni: str
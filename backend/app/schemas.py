from datetime import time

from pydantic import BaseModel

from datetime import date, time


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


class SlotResponse(BaseModel):
    hora: str
    disponible: bool


class ReservaCreate(BaseModel):
    cancha_id: int
    fecha: date
    hora_inicio: time
    hora_fin: time


class ReservaResponse(BaseModel):
    id: int
    cancha_id: int
    fecha: date
    hora_inicio: time
    hora_fin: time
    estado: str

class ReservaDetalleResponse(BaseModel):
    id: int
    sede: str
    cancha: str
    fecha: date
    hora_inicio: time
    hora_fin: time
    estado: str
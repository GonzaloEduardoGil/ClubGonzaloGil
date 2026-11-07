from datetime import date, datetime, time
from decimal import Decimal

from sqlalchemy import Date, DateTime, ForeignKey, Numeric, String, Time, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .db import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True)
    firebase_uid: Mapped[str] = mapped_column(String(128), unique=True)
    nombre: Mapped[str] = mapped_column(String(100))
    apellido: Mapped[str] = mapped_column(String(100))
    email: Mapped[str] = mapped_column(String(150), unique=True)
    fecha_nacimiento: Mapped[date] = mapped_column(Date)
    dni: Mapped[str] = mapped_column(String(20), unique=True)

    reservas: Mapped[list["Reserva"]] = relationship(back_populates="usuario")


class Sede(Base):
    __tablename__ = "sedes"

    id: Mapped[int] = mapped_column(primary_key=True)
    nombre: Mapped[str] = mapped_column(String(100), unique=True)
    direccion: Mapped[str] = mapped_column(String(200))
    hora_apertura: Mapped[time] = mapped_column(Time)
    hora_cierre: Mapped[time] = mapped_column(Time)

    canchas: Mapped[list["Cancha"]] = relationship(
        back_populates="sede",
        cascade="all, delete-orphan",
    )


class Cancha(Base):
    __tablename__ = "canchas"

    id: Mapped[int] = mapped_column(primary_key=True)
    sede_id: Mapped[int] = mapped_column(ForeignKey("sedes.id"))
    nombre: Mapped[str] = mapped_column(String(150), unique=True)
    deporte: Mapped[str] = mapped_column(String(50))
    tipo: Mapped[str | None] = mapped_column(String(50), nullable=True)
    precio_por_hora: Mapped[Decimal] = mapped_column(Numeric(10, 2))

    sede: Mapped["Sede"] = relationship(back_populates="canchas")
    reservas: Mapped[list["Reserva"]] = relationship(back_populates="cancha")


class Reserva(Base):
    __tablename__ = "reservas"

    id: Mapped[int] = mapped_column(primary_key=True)
    usuario_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    cancha_id: Mapped[int] = mapped_column(ForeignKey("canchas.id"))
    fecha: Mapped[date] = mapped_column(Date)
    hora_inicio: Mapped[time] = mapped_column(Time)
    hora_fin: Mapped[time] = mapped_column(Time)
    estado: Mapped[str] = mapped_column(String(20), default="confirmada")
    
    creada_en: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
    )
    reminder_24h_sent_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
    )
    reminder_1h_sent_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
    )

    usuario: Mapped["User"] = relationship(back_populates="reservas")
    cancha: Mapped["Cancha"] = relationship(back_populates="reservas")

class DeviceToken(Base):
    __tablename__ = "device_tokens"

    id: Mapped[int] = mapped_column(primary_key=True)
    usuario_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
    )
    token: Mapped[str] = mapped_column(String(512), unique=True)
from datetime import time
from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session

from .models import Cancha, Sede


def cargar_datos_iniciales(db: Session) -> None:
    # Si ya existen sedes, no vuelve a insertar datos.
    if db.scalar(select(Sede.id).limit(1)) is not None:
        return

    sede_norte = Sede(
        nombre="Sede Norte",
        direccion="Av. Libertador 1200",
        hora_apertura=time(8, 0),
        hora_cierre=time(23, 0),
    )

    sede_centro = Sede(
        nombre="Sede Centro",
        direccion="Calle San Martín 450",
        hora_apertura=time(7, 0),
        hora_cierre=time(22, 0),
    )

    sede_sur = Sede(
        nombre="Sede Sur",
        direccion="Ruta 8 km 24",
        hora_apertura=time(9, 0),
        hora_cierre=time(21, 0),
    )

    sede_este = Sede(
        nombre="Sede Este",
        direccion="Av. Mitre 780",
        hora_apertura=time(10, 0),
        hora_cierre=time(23, 0),
    )

    db.add_all([sede_norte, sede_centro, sede_sur, sede_este])
    db.flush()

    db.add_all([
        Cancha(
            sede=sede_norte,
            nombre="Norte_Libertador_1200_Futbol_1",
            deporte="Fútbol",
            tipo="Fútbol 5",
            precio_por_hora=Decimal("8000"),
        ),
        Cancha(
            sede=sede_norte,
            nombre="Norte_Libertador_1200_Futbol_2",
            deporte="Fútbol",
            tipo="Fútbol 11",
            precio_por_hora=Decimal("15000"),
        ),
        Cancha(
            sede=sede_norte,
            nombre="Norte_Libertador_1200_Tenis_1",
            deporte="Tenis",
            tipo=None,
            precio_por_hora=Decimal("5000"),
        ),
        Cancha(
            sede=sede_centro,
            nombre="Centro_SanMartin_450_Futbol_1",
            deporte="Fútbol",
            tipo="Fútbol 5",
            precio_por_hora=Decimal("8000"),
        ),
        Cancha(
            sede=sede_centro,
            nombre="Centro_SanMartin_450_Golf_1",
            deporte="Golf",
            tipo=None,
            precio_por_hora=Decimal("12000"),
        ),
        Cancha(
            sede=sede_sur,
            nombre="Sur_Ruta8_24_Tenis_1",
            deporte="Tenis",
            tipo=None,
            precio_por_hora=Decimal("5000"),
        ),
        Cancha(
            sede=sede_sur,
            nombre="Sur_Ruta8_24_Hockey_1",
            deporte="Hockey",
            tipo=None,
            precio_por_hora=Decimal("9000"),
        ),
        Cancha(
            sede=sede_este,
            nombre="Este_Mitre_780_Futbol_1",
            deporte="Fútbol",
            tipo="Fútbol 5",
            precio_por_hora=Decimal("8000"),
        ),
    ])

    db.commit()
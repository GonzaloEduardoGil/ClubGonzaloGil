import asyncio
from .routers.sedes import router as sedes_router
from .seed import cargar_datos_iniciales

from contextlib import asynccontextmanager, suppress

from fastapi import FastAPI

from . import models
from .db import Base, SessionLocal, engine
from .firebase import initialize_firebase
from .routers.users import router as users_router
from .routers.reservas import router as reservas_router
from .routers.canchas import router as canchas_router
from .routers.device_tokens import router as device_tokens_router
from .notifier import ejecutar_recordatorios


@asynccontextmanager
async def lifespan(app: FastAPI):
    initialize_firebase()
    Base.metadata.create_all(bind=engine)

    with SessionLocal() as db:
        cargar_datos_iniciales(db)

    tarea_recordatorios = asyncio.create_task(
        ejecutar_recordatorios(),
    )

    yield

    tarea_recordatorios.cancel()

    with suppress(asyncio.CancelledError):
        await tarea_recordatorios
app = FastAPI(
    title="Club Gonzalo Gil API",
    description="API para la gestión de sedes, canchas y reservas deportivas.",
    version="1.0.0",
    lifespan=lifespan,
)

app.include_router(sedes_router)
@app.get("/health")
def health_check():
    return {"status": "ok", "message": "API de Club Gonzalo Gil funcionando"}
app.include_router(sedes_router)
app.include_router(users_router)
app.include_router(reservas_router)
app.include_router(canchas_router)
app.include_router(device_tokens_router)
from .routers.sedes import router as sedes_router
from .seed import cargar_datos_iniciales

from contextlib import asynccontextmanager

from fastapi import FastAPI

from . import models
from .db import Base, SessionLocal, engine


@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine)

    with SessionLocal() as db:
        cargar_datos_iniciales(db)

    yield


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
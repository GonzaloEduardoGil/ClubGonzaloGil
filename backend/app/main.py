from contextlib import asynccontextmanager

from fastapi import FastAPI

from . import models
from .db import Base, engine


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Crea las tablas definidas en models.py si todavía no existen.
    Base.metadata.create_all(bind=engine)
    yield


app = FastAPI(
    title="Club Gonzalo Gil API",
    description="API para la gestión de sedes, canchas y reservas deportivas.",
    version="1.0.0",
    lifespan=lifespan,
)


@app.get("/health")
def health_check():
    return {"status": "ok", "message": "API de Club Gonzalo Gil funcionando"}
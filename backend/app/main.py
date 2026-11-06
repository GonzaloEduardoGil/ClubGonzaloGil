from fastapi import FastAPI

# FastAPI crea automáticamente la documentación Swagger en /docs.
app = FastAPI(
    title="Club Gonzalo Gil API",
    description="API para la gestión de sedes, canchas y reservas deportivas.",
    version="1.0.0",
)


@app.get("/health")
def health_check():
    """Permite comprobar que el servidor está funcionando."""
    return {"status": "ok", "message": "API de Club Gonzalo Gil funcionando"}
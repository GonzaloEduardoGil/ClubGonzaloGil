import firebase_admin
from firebase_admin import auth, messaging


def initialize_firebase() -> None:
    try:
        firebase_admin.get_app()
    except ValueError:
        # Usa GOOGLE_APPLICATION_CREDENTIALS, que configuraste en PowerShell.
        firebase_admin.initialize_app()


def verify_firebase_token(id_token: str) -> str:
    initialize_firebase()

    decoded_token = auth.verify_id_token(id_token)

    return decoded_token["uid"]

def enviar_notificacion(
    tokens: list[str],
    titulo: str,
    cuerpo: str,
) -> None:
    if not tokens:
        return

    mensaje = messaging.MulticastMessage(
        notification=messaging.Notification(
            title=titulo,
            body=cuerpo,
        ),
        tokens=tokens,
    )

    messaging.send_each_for_multicast(mensaje)
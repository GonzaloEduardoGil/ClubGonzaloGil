import json

import firebase_admin
from firebase_admin import auth, credentials, messaging

from .config import settings


def initialize_firebase() -> None:
    try:
        firebase_admin.get_app()
        return
    except ValueError:
        pass

    if settings.firebase_service_account_json is not None:
        service_account = json.loads(
            settings.firebase_service_account_json,
        )

        firebase_admin.initialize_app(
            credentials.Certificate(service_account),
        )
    else:
        # Uso local: GOOGLE_APPLICATION_CREDENTIALS.
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
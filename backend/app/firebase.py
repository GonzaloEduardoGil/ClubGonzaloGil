import firebase_admin
from firebase_admin import auth


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
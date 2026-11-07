from urllib.parse import quote_plus

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # Render usará esta variable. En local puede quedar vacía.
    database_url: str | None = Field(
        default=None,
        validation_alias="DATABASE_URL",
    )

    db_user: str = "postgres"
    db_password: str | None = None
    db_host: str = "localhost"
    db_port: int = 5432
    db_name: str = "club_gonzalo_gil"

    # En Render contendrá el JSON de la cuenta de servicio de Firebase.
    firebase_service_account_json: str | None = None

    model_config = SettingsConfigDict(
        env_file=".env",
        extra="ignore",
    )

    @property
    def sqlalchemy_database_url(self) -> str:
        if self.database_url is not None:
            if self.database_url.startswith("postgresql+psycopg://"):
                return self.database_url

            if self.database_url.startswith("postgres://"):
                return self.database_url.replace(
                    "postgres://",
                    "postgresql+psycopg://",
                    1,
                )

            if self.database_url.startswith("postgresql://"):
                return self.database_url.replace(
                    "postgresql://",
                    "postgresql+psycopg://",
                    1,
                )

            return self.database_url

        if self.db_password is None:
            raise ValueError("Falta DB_PASSWORD o DATABASE_URL.")

        password = quote_plus(self.db_password)

        return (
            f"postgresql+psycopg://{self.db_user}:{password}"
            f"@{self.db_host}:{self.db_port}/{self.db_name}"
        )


settings = Settings()
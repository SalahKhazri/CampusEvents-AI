from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    APP_NAME: str = "CampusEvents AI"
    DATABASE_URL: str = "sqlite:///./campus_events.db"
    OLLAMA_URL: str = "http://localhost:11434/api/generate"
    OLLAMA_MODEL: str = "llama3"
    LLM_MAX_CONTEXT: int = 8000
    ADMIN_EMAIL: str = "admin@campus.ma"
    ADMIN_PASSWORD: str = "admin123"
    STUDENT_EMAIL: str = "etudiant@campus.ma"
    STUDENT_PASSWORD: str = "etudiant123"

    class Config:
        env_file = ".env"


settings = Settings()

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.database import engine, Base
from app.routers import auth, events, registrations, favorites, llm
from app.seed import seed_database

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title=settings.APP_NAME,
    description="API de gestion d'événements universitaires avec assistant IA",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(events.router)
app.include_router(registrations.router)
app.include_router(favorites.router)
app.include_router(llm.router)


@app.on_event("startup")
def startup():
    seed_database()


@app.get("/")
def root():
    return {"message": "Bienvenue sur CampusEvents AI API", "version": "1.0.0"}


@app.get("/health")
def health():
    return {"status": "ok"}

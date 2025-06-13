# ai-one/ai_one_api/app/main.py

from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from fastapi.middleware.cors import CORSMiddleware

from . import models
from .database import engine, get_db
from .routers import contacts
from .routers import notes         # <<<-- DECOMMENTEZ OU AJOUTEZ CETTE LIGNE
from .routers import credentials  # <<<-- DECOMMENTEZ OU AJOUTEZ CETTE LIGNE
from .routers import tasks        # <<<-- DECOMMENTEZ OU AJOUTEZ CETTE LIGNE

# Créer les tables dans la base de données (si elles n'existent pas)
models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Ai One API",
    description="API de centralisation pour la gestion des contacts, notes, informations sensibles et tâches.",
    version="1.0.0",
)

# Configuration CORS (reste inchangée)
origins = [
    "http://localhost",
    "http://localhost:8000",
    "http://localhost:3000",
    "http://127.0.0.1:8000",
    "http://127.0.0.1:3000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Inclure les routeurs
app.include_router(contacts.router)
app.include_router(notes.router)        # <<<-- DECOMMENTEZ CETTE LIGNE
app.include_router(credentials.router)  # <<<-- DECOMMENTEZ CETTE LIGNE
app.include_router(tasks.router)        # <<<-- DECOMMENTEZ CETTE LIGNE

@app.get("/")
async def root():
    return {"message": "Bienvenue sur l'API Ai One !"}
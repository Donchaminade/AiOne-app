# ai-one/ai_one_api/app/database.py

import os
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv

# Charger les variables d'environnement depuis le fichier .env
load_dotenv()

# Récupérer les informations de connexion depuis les variables d'environnement
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "3306")
DB_NAME = os.getenv("DB_NAME", "ai_one_db")
DB_USER = os.getenv("DB_USER", "root")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")

# Construire l'URL de connexion à la base de données
# Le driver pymysql est 'mysql+pymysql' <--- C'EST LE CHANGEMENT IMPORTANT ICI
DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

# Créer un moteur de base de données SQLAlchemy
engine = create_engine(DATABASE_URL, echo=True)

# Créer une session locale (chaque requête API aura sa propre session)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base de déclaration pour les modèles SQLAlchemy
Base = declarative_base()

# Fonction d'utilité pour obtenir une session de base de données
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
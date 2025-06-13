# ai-one/ai_one_api/app/models.py

from sqlalchemy import Column, Integer, String, Text, DateTime, Date, Enum
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql import func # Pour func.now() si besoin pour created_at/updated_at

Base = declarative_base()

class Contact(Base):
    __tablename__ = "contacts"

    id = Column(Integer, primary_key=True, index=True)
    nom_complet = Column(String(255), nullable=False) # Changé de nom/prenom
    profession = Column(String(255), nullable=True) # Nouveau
    numero_telephone = Column(String(50), nullable=True)
    adresse_email = Column(String(255), unique=True, nullable=False)
    adresse = Column(String(255), nullable=True) # Nouveau (anciennement adresse_postale)
    entreprise_organisation = Column(String(255), nullable=True) # Nouveau
    date_naissance = Column(Date, nullable=True) # Nouveau
    tags_labels = Column(Text, nullable=True) # Nouveau
    notes_specifiques = Column(Text, nullable=True) # Nouveau (anciennement notes)
    created_at = Column(DateTime, default=func.now()) # Correspondent à votre DB
    updated_at = Column(DateTime, onupdate=func.now()) # Correspond à votre DB

class Note(Base):
    __tablename__ = "notes"

    id = Column(Integer, primary_key=True, index=True)
    titre = Column(String(255), nullable=False)
    sous_titre = Column(String(255), nullable=True) # Nouveau
    contenu = Column(Text, nullable=True)
    dossiers = Column(Text, nullable=True) # Nouveau
    tags_labels = Column(Text, nullable=True) # Nouveau
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, onupdate=func.now())

class Credential(Base):
    __tablename__ = "credentials"

    id = Column(Integer, primary_key=True, index=True)
    nom_site_compte = Column(String(255), nullable=False)
    nom_utilisateur_email = Column(String(255), nullable=False)
    mot_de_passe_chiffre = Column(String(512), nullable=False)
    autres_infos_chiffre = Column(Text, nullable=True)
    categorie = Column(String(100), nullable=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, onupdate=func.now())

class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    titre_tache = Column(String(255), nullable=False) # Changé de titre
    date_heure_debut = Column(DateTime, nullable=False) # Nouveau
    date_heure_fin = Column(DateTime, nullable=True) # Changé de date_echeance
    details_description = Column(Text, nullable=True) # Changé de description
    priorite = Column(Enum('Haute', 'Moyenne', 'Basse'), nullable=True) # Nouveau
    statut = Column(Enum('À faire', 'En cours', 'Terminé', 'Annulé'), nullable=True) # Changé de est_complete
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, onupdate=func.now())
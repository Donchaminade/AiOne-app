# ai-one/ai_one_api/app/schemas.py

from typing import Optional, List
from datetime import datetime, date # Importez date pour date_naissance
from pydantic import BaseModel, EmailStr, Field # Importez Field si vous utilisez des valeurs par défaut complexes


# --- Schémas pour Contact ---
class ContactBase(BaseModel):
    nom_complet: str # Correspond à la DB
    profession: Optional[str] = None # Nouveau
    numero_telephone: Optional[str] = None
    adresse_email: EmailStr
    adresse: Optional[str] = None # Correspond à la DB (anciennement adresse_postale)
    entreprise_organisation: Optional[str] = None # Nouveau
    date_naissance: Optional[date] = None # Nouveau, type date
    tags_labels: Optional[str] = None # Nouveau (texte)
    notes_specifiques: Optional[str] = None # Correspond à la DB (anciennement notes)

class ContactCreate(ContactBase):
    pass # Hérite de ContactBase

class ContactUpdate(BaseModel):
    nom_complet: Optional[str] = None
    profession: Optional[str] = None
    numero_telephone: Optional[str] = None
    adresse_email: Optional[EmailStr] = None
    adresse: Optional[str] = None
    entreprise_organisation: Optional[str] = None
    date_naissance: Optional[date] = None
    tags_labels: Optional[str] = None
    notes_specifiques: Optional[str] = None

class Contact(ContactBase):
    id: int
    created_at: datetime # Correspond à la DB
    updated_at: Optional[datetime] = None # Nouveau, peut être null

    class Config:
        from_attributes = True

# --- Schémas pour Note ---
class NoteBase(BaseModel):
    titre: str
    sous_titre: Optional[str] = None # Nouveau
    contenu: Optional[str] = None
    dossiers: Optional[str] = None # Nouveau (texte)
    tags_labels: Optional[str] = None # Nouveau (texte)

class NoteCreate(NoteBase):
    pass

class NoteUpdate(BaseModel):
    titre: Optional[str] = None
    sous_titre: Optional[str] = None
    contenu: Optional[str] = None
    dossiers: Optional[str] = None
    tags_labels: Optional[str] = None

class Note(NoteBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True

# --- Schémas pour Credential ---
class CredentialBase(BaseModel):
    nom_site_compte: str
    nom_utilisateur_email: str
    categorie: Optional[str] = None

class CredentialCreate(CredentialBase):
    mot_de_passe: str # Mot de passe en clair pour l'entrée
    autres_infos: Optional[str] = None # Autres infos en clair pour l'entrée

class CredentialUpdate(CredentialBase):
    nom_site_compte: Optional[str] = None
    nom_utilisateur_email: Optional[str] = None
    mot_de_passe: Optional[str] = None # Mot de passe en clair pour la mise à jour
    autres_infos: Optional[str] = None
    categorie: Optional[str] = None

class Credential(CredentialBase):
    id: int
    mot_de_passe_chiffre: Optional[str] = None # Le champ chiffré renvoyé
    autres_infos_chiffre: Optional[str] = None # Le champ chiffré renvoyé
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True

# --- Schémas pour Task ---
class TaskBase(BaseModel):
    titre_tache: str # Correspond à la DB (anciennement titre)
    date_heure_debut: datetime # Correspond à la DB, requis
    date_heure_fin: Optional[datetime] = None # Correspond à la DB (anciennement date_echeance)
    details_description: Optional[str] = None # Correspond à la DB (anciennement description)
    priorite: Optional[str] = None # Correspond à la DB (enum)
    statut: Optional[str] = Field("À faire", description="Statut de la tâche, ex: 'À faire', 'En cours', 'Terminé', 'Annulé'") # Correspond à la DB (enum)

class TaskCreate(TaskBase):
    pass

class TaskUpdate(BaseModel):
    titre_tache: Optional[str] = None
    date_heure_debut: Optional[datetime] = None
    date_heure_fin: Optional[datetime] = None
    details_description: Optional[str] = None
    priorite: Optional[str] = None
    statut: Optional[str] = None

class Task(TaskBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True
# ai-one/ai_one_api/app/crud.py

from sqlalchemy.orm import Session
from typing import Optional
from . import models, schemas
from .core.security import encrypt_aes, decrypt_aes
from datetime import datetime # Assurez-vous que datetime est importé


# --- Opérations CRUD pour Contact ---
def get_contact(db: Session, contact_id: Optional[int] = None, email: Optional[str] = None):
    if contact_id:
        return db.query(models.Contact).filter(models.Contact.id == contact_id).first()
    if email:
        return db.query(models.Contact).filter(models.Contact.adresse_email == email).first()
    return None

def get_contacts(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Contact).offset(skip).limit(limit).all()

def create_contact(db: Session, contact: schemas.ContactCreate):
    # Utilisez le nom de colonne de la DB : nom_complet, adresse, notes_specifiques etc.
    db_contact = models.Contact(
        nom_complet=contact.nom_complet,
        profession=contact.profession,
        numero_telephone=contact.numero_telephone,
        adresse_email=contact.adresse_email,
        adresse=contact.adresse,
        entreprise_organisation=contact.entreprise_organisation,
        date_naissance=contact.date_naissance,
        tags_labels=contact.tags_labels,
        notes_specifiques=contact.notes_specifiques,
        created_at=datetime.now() # Définissez created_at explicitement
    )
    db.add(db_contact)
    db.commit()
    db.refresh(db_contact)
    return db_contact

def update_contact(db: Session, contact_id: int, contact: schemas.ContactUpdate):
    db_contact = db.query(models.Contact).filter(models.Contact.id == contact_id).first()
    if db_contact:
        for key, value in contact.dict(exclude_unset=True).items():
            # Mappage des champs si les noms de schéma diffèrent des noms de colonne du modèle
            # Dans ce cas, les noms des champs du schéma correspondent aux noms des colonnes du modèle après les ajustements.
            setattr(db_contact, key, value)
        db.commit()
        db.refresh(db_contact)
    return db_contact

def delete_contact(db: Session, contact_id: int):
    db_contact = db.query(models.Contact).filter(models.Contact.id == contact_id).first()
    if db_contact:
        db.delete(db_contact)
        db.commit()
        return True
    return False

# --- Opérations CRUD pour Note ---
def get_note(db: Session, note_id: int):
    return db.query(models.Note).filter(models.Note.id == note_id).first()

def get_notes(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Note).offset(skip).limit(limit).all()

def create_note(db: Session, note: schemas.NoteCreate):
    db_note = models.Note(
        titre=note.titre,
        sous_titre=note.sous_titre,
        contenu=note.contenu,
        dossiers=note.dossiers,
        tags_labels=note.tags_labels,
        created_at=datetime.now() # Définissez created_at explicitement
    )
    db.add(db_note)
    db.commit()
    db.refresh(db_note)
    return db_note

def update_note(db: Session, note_id: int, note: schemas.NoteUpdate):
    db_note = db.query(models.Note).filter(models.Note.id == note_id).first()
    if db_note:
        for key, value in note.dict(exclude_unset=True).items():
            setattr(db_note, key, value)
        db.commit()
        db.refresh(db_note)
    return db_note

def delete_note(db: Session, note_id: int):
    db_note = db.query(models.Note).filter(models.Note.id == note_id).first()
    if db_note:
        db.delete(db_note)
        db.commit()
        return True
    return False

# --- Opérations CRUD pour Credential (avec chiffrement) ---
def get_credential(db: Session, credential_id: int):
    db_credential = db.query(models.Credential).filter(models.Credential.id == credential_id).first()
    if db_credential:
        # On déchiffre pour le renvoyer, mais il faut être prudent avec la modification de l'objet ORM.
        # Idéalement, on construirait un nouveau Pydantic model avec les champs déchiffrés.
        if db_credential.mot_de_passe_chiffre:
            db_credential.mot_de_passe_chiffre = decrypt_aes(db_credential.mot_de_passe_chiffre)
        if db_credential.autres_infos_chiffre:
            db_credential.autres_infos_chiffre = decrypt_aes(db_credential.autres_infos_chiffre)
    return db_credential

def get_credentials(db: Session, skip: int = 0, limit: int = 100):
    # ATTENTION: Ne déchiffrez PAS les mots de passe ici pour la liste !
    return db.query(models.Credential).offset(skip).limit(limit).all()

def create_credential(db: Session, credential: schemas.CredentialCreate):
    encrypted_password = encrypt_aes(credential.mot_de_passe)
    encrypted_other_info = encrypt_aes(credential.autres_infos) if credential.autres_infos else None

    db_credential = models.Credential(
        nom_site_compte=credential.nom_site_compte,
        nom_utilisateur_email=credential.nom_utilisateur_email,
        mot_de_passe_chiffre=encrypted_password,
        autres_infos_chiffre=encrypted_other_info,
        categorie=credential.categorie,
        created_at=datetime.now() # Définissez created_at explicitement
    )
    db.add(db_credential)
    db.commit()
    db.refresh(db_credential)
    return db_credential

def update_credential(db: Session, credential_id: int, credential: schemas.CredentialUpdate):
    db_credential = db.query(models.Credential).filter(models.Credential.id == credential_id).first()
    if db_credential:
        for key, value in credential.dict(exclude_unset=True).items():
            if key == "mot_de_passe" and value is not None:
                db_credential.mot_de_passe_chiffre = encrypt_aes(value)
            elif key == "autres_infos" and value is not None:
                db_credential.autres_infos_chiffre = encrypt_aes(value)
            else: # Pour les autres champs, comme nom_site_compte, nom_utilisateur_email, categorie
                setattr(db_credential, key, value)
        db.commit()
        db.refresh(db_credential)
    return db_credential

def delete_credential(db: Session, credential_id: int):
    db_credential = db.query(models.Credential).filter(models.Credential.id == credential_id).first()
    if db_credential:
        db.delete(db_credential)
        db.commit()
        return True
    return False

# --- Opérations CRUD pour Task ---
def get_task(db: Session, task_id: int):
    return db.query(models.Task).filter(models.Task.id == task_id).first()

def get_tasks(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Task).offset(skip).limit(limit).all()

def create_task(db: Session, task: schemas.TaskCreate):
    db_task = models.Task(
        titre_tache=task.titre_tache, # Utilisez le nom de colonne de la DB
        date_heure_debut=task.date_heure_debut,
        date_heure_fin=task.date_heure_fin,
        details_description=task.details_description, # Utilisez le nom de colonne de la DB
        priorite=task.priorite,
        statut=task.statut,
        created_at=datetime.now() # Définissez created_at explicitement
    )
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    return db_task

def update_task(db: Session, task_id: int, task: schemas.TaskUpdate):
    db_task = db.query(models.Task).filter(models.Task.id == task_id).first()
    if db_task:
        # Mappage des champs si les noms de schéma diffèrent des noms de colonne du modèle
        if task.titre_tache is not None:
            db_task.titre_tache = task.titre_tache
        if task.date_heure_debut is not None:
            db_task.date_heure_debut = task.date_heure_debut
        if task.date_heure_fin is not None:
            db_task.date_heure_fin = task.date_heure_fin
        if task.details_description is not None:
            db_task.details_description = task.details_description
        if task.priorite is not None:
            db_task.priorite = task.priorite
        if task.statut is not None:
            db_task.statut = task.statut
        db.commit()
        db.refresh(db_task)
    return db_task

def delete_task(db: Session, task_id: int):
    db_task = db.query(models.Task).filter(models.Task.id == task_id).first()
    if db_task:
        db.delete(db_task)
        db.commit()
        return True
    return False
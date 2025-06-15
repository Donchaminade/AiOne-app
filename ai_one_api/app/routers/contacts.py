# ai-one/ai_one_api/app/routers/contacts.py

# Utilisation de `list` au lieu de `List` est la nouvelle syntaxe recommandée en Python 3.9+
# Si vous utilisez une version de Python antérieure à 3.9, gardez `from typing import List`
# et utilisez `List[schemas.Contact]`
from typing import List # Gardez ceci si vous êtes sur Python < 3.9
# from typing import list # Si vous êtes sur Python 3.9+ et que vous préférez la nouvelle syntaxe

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from .. import crud, schemas # Assurez-vous que schemas.Contact est bien défini dans schemas.py
from ..database import get_db

# --- REMARQUE IMPORTANTE ---
# Si vous aviez importé des modules d'authentification ici (ex: get_current_user),
# assurez-vous qu'ils sont bien supprimés !
# Par exemple:
# from ..routers.auth import get_current_user # <<<--- À SUPPRIMER
# from ..models import User # <<<--- À SUPPRIMER si User n'est plus utilisé pour l'authentification

router = APIRouter(
    prefix="/contacts",
    tags=["Contacts"]
)

@router.post("/", response_model=schemas.Contact, status_code=status.HTTP_201_CREATED)
def create_contact_endpoint(contact: schemas.ContactCreate, db: Session = Depends(get_db)):
    # Pas de 'user_id' passé ici, ce qui est cohérent avec le crud.py fourni et l'absence d'authentification.
    return crud.create_contact(db=db, contact=contact)

# REMARQUE sur response_model:
# Si votre schéma de réponse pour un contact est `ContactResponse` (comme c'était souvent le cas
# quand on avait un `user_id` en plus), alors remplacez `schemas.Contact` par `schemas.ContactResponse` ici.
# Si `schemas.Contact` est déjà votre schéma complet pour la lecture/réponse, c'est bon.
@router.get("/", response_model=List[schemas.Contact]) # Utilisez `list[schemas.Contact]` pour Python 3.9+
def read_contacts_endpoint(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    # Pas de filtrage par user_id, ce qui est cohérent.
    contacts = crud.get_contacts(db, skip=skip, limit=limit)
    return contacts

@router.get("/{contact_id}", response_model=schemas.Contact) # Idem que ci-dessus, `schemas.Contact` ou `schemas.ContactResponse`
def read_contact_endpoint(contact_id: int, db: Session = Depends(get_db)):
    db_contact = crud.get_contact(db, contact_id=contact_id)
    if db_contact is None:
        raise HTTPException(status_code=404, detail="Contact not found")
    # Pas de vérification de user_id, ce qui est cohérent.
    return db_contact

@router.put("/{contact_id}", response_model=schemas.Contact) # Idem que ci-dessus, `schemas.Contact` ou `schemas.ContactResponse`
def update_contact_endpoint(contact_id: int, contact: schemas.ContactUpdate, db: Session = Depends(get_db)):
    db_contact = crud.update_contact(db, contact_id=contact_id, contact=contact)
    if db_contact is None:
        raise HTTPException(status_code=404, detail="Contact not found")
    # Pas de vérification de user_id, ce qui est cohérent.
    return db_contact

@router.delete("/{contact_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_contact_endpoint(contact_id: int, db: Session = Depends(get_db)):
    success = crud.delete_contact(db, contact_id=contact_id)
    if not success:
        raise HTTPException(status_code=404, detail="Contact not found")
    # Pas de vérification de user_id, ce qui est cohérent.
    return {"message": "Contact deleted successfully"} # FastAPI renverra un corps vide pour 204
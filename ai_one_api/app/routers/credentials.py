from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from .. import crud, schemas
from ..database import get_db
from ..core.security import decrypt_aes # Pour le déchiffrement lors de la lecture

router = APIRouter(
    prefix="/credentials",
    tags=["Credentials"]
)

@router.post("/", response_model=schemas.Credential, status_code=status.HTTP_201_CREATED)
def create_credential_endpoint(credential: schemas.CredentialCreate, db: Session = Depends(get_db)):
    # Le chiffrement est géré dans crud.create_credential
    return crud.create_credential(db=db, credential=credential)

@router.get("/", response_model=List[schemas.CredentialBase]) # Utilisez CredentialBase pour ne pas exposer le mot de passe dans la liste
def read_credentials_endpoint(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    credentials = crud.get_credentials(db, skip=skip, limit=limit)
    # Important : Ne pas déchiffrer les mots de passe ici pour une liste complète.
    # Les champs chiffrés doivent rester chiffrés dans la liste pour des raisons de sécurité.
    return credentials

@router.get("/{credential_id}", response_model=schemas.Credential)
def read_credential_endpoint(credential_id: int, db: Session = Depends(get_db)):
    db_credential = crud.get_credential(db, credential_id=credential_id)
    if db_credential is None:
        raise HTTPException(status_code=404, detail="Credential not found")
    # `get_credential` dans crud.py déchiffre déjà le mot de passe pour cette vue détaillée
    return db_credential

@router.put("/{credential_id}", response_model=schemas.Credential)
def update_credential_endpoint(credential_id: int, credential: schemas.CredentialUpdate, db: Session = Depends(get_db)):
    # Le chiffrement du nouveau mot de passe est géré dans crud.update_credential
    db_credential = crud.update_credential(db, credential_id=credential_id, credential=credential)
    if db_credential is None:
        raise HTTPException(status_code=404, detail="Credential not found")
    return db_credential

@router.delete("/{credential_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_credential_endpoint(credential_id: int, db: Session = Depends(get_db)):
    success = crud.delete_credential(db, credential_id=credential_id)
    if not success:
        raise HTTPException(status_code=404, detail="Credential not found")
    return {"message": "Credential deleted successfully"}
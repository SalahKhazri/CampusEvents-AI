from typing import List
from fastapi import APIRouter, Depends, HTTPException, Header
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.registration import RegistrationCreate, RegistrationResponse
from app.services.registration_service import RegistrationService

router = APIRouter(prefix="/api/registrations", tags=["Inscriptions"])


def get_reg_service(db: Session = Depends(get_db)) -> RegistrationService:
    return RegistrationService(db)


@router.get("/", response_model=List[RegistrationResponse])
def get_user_registrations(
    user_email: str = Header(...),
    service: RegistrationService = Depends(get_reg_service),
):
    return service.get_user_registrations(user_email)


@router.get("/check/{event_id}")
def check_registration(
    event_id: int,
    user_email: str = Header(...),
    service: RegistrationService = Depends(get_reg_service),
):
    return {"is_registered": service.is_registered(event_id, user_email)}


@router.post("/", status_code=201)
def register(
    data: RegistrationCreate,
    user_email: str = Header(...),
    service: RegistrationService = Depends(get_reg_service),
):
    result = service.register(data.event_id, user_email)
    if not result["success"]:
        raise HTTPException(status_code=400, detail=result["message"])
    return result


@router.delete("/{event_id}")
def cancel_registration(
    event_id: int,
    user_email: str = Header(...),
    service: RegistrationService = Depends(get_reg_service),
):
    result = service.cancel(event_id, user_email)
    if not result["success"]:
        raise HTTPException(status_code=400, detail=result["message"])
    return result

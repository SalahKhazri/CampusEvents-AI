from typing import List
from sqlalchemy.orm import Session

from app.repositories.registration_repository import RegistrationRepository
from app.repositories.event_repository import EventRepository
from app.schemas.registration import RegistrationResponse
from app.schemas.event import EventResponse


class RegistrationService:
    def __init__(self, db: Session):
        self.repo = RegistrationRepository(db)
        self.event_repo = EventRepository(db)

    def get_user_registrations(self, user_email: str) -> List[RegistrationResponse]:
        regs = self.repo.get_by_user(user_email)
        return [
            RegistrationResponse(
                id=r.id,
                event_id=r.event_id,
                user_email=r.user_email,
                registered_at=r.registered_at.isoformat() if r.registered_at else None,
                is_cancelled=r.is_cancelled,
            )
            for r in regs
        ]

    def register(self, event_id: int, user_email: str) -> dict:
        event = self.event_repo.get_by_id(event_id)
        if not event:
            return {"success": False, "message": "Événement introuvable"}

        if self.repo.is_registered(event_id, user_email):
            return {"success": False, "message": "Vous êtes déjà inscrit à cet événement"}

        current_count = self.repo.count_by_event(event_id)
        if current_count >= event.capacity:
            return {"success": False, "message": "Cet événement est complet"}

        self.repo.create(event_id, user_email)
        return {"success": True, "message": "Inscription réussie"}

    def cancel(self, event_id: int, user_email: str) -> dict:
        reg = self.repo.get_user_registration(event_id, user_email)
        if not reg:
            return {"success": False, "message": "Aucune inscription trouvée"}
        self.repo.cancel(reg)
        return {"success": True, "message": "Inscription annulée"}

    def is_registered(self, event_id: int, user_email: str) -> bool:
        return self.repo.is_registered(event_id, user_email)

    def get_registered_event_ids(self, user_email: str) -> List[int]:
        regs = self.repo.get_by_user(user_email)
        return [r.event_id for r in regs]

    def get_user_favorite_event_ids(self, user_email: str) -> List[int]:
        return self.repo.get_user_favorite_event_ids(user_email)

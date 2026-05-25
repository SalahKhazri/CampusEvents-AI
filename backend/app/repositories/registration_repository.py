from sqlalchemy.orm import Session
from sqlalchemy import and_
from typing import List

from app.models.registration import Registration


class RegistrationRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_user(self, user_email: str) -> List[Registration]:
        return (
            self.db.query(Registration)
            .filter(
                Registration.user_email == user_email,
                Registration.is_cancelled == 0,
            )
            .all()
        )

    def get_by_event(self, event_id: int) -> List[Registration]:
        return (
            self.db.query(Registration)
            .filter(
                Registration.event_id == event_id,
                Registration.is_cancelled == 0,
            )
            .all()
        )

    def get_user_registration(self, event_id: int, user_email: str) -> Registration | None:
        return (
            self.db.query(Registration)
            .filter(
                Registration.event_id == event_id,
                Registration.user_email == user_email,
                Registration.is_cancelled == 0,
            )
            .first()
        )

    def create(self, event_id: int, user_email: str) -> Registration:
        reg = Registration(event_id=event_id, user_email=user_email)
        self.db.add(reg)
        self.db.commit()
        self.db.refresh(reg)
        return reg

    def cancel(self, registration: Registration) -> Registration:
        registration.is_cancelled = 1
        self.db.commit()
        self.db.refresh(registration)
        return registration

    def is_registered(self, event_id: int, user_email: str) -> bool:
        return (
            self.db.query(Registration)
            .filter(
                Registration.event_id == event_id,
                Registration.user_email == user_email,
                Registration.is_cancelled == 0,
            )
            .first()
            is not None
        )

    def count_by_event(self, event_id: int) -> int:
        return (
            self.db.query(Registration)
            .filter(
                Registration.event_id == event_id,
                Registration.is_cancelled == 0,
            )
            .count()
        )

    def get_user_favorite_event_ids(self, user_email: str) -> List[int]:
        from app.models.favorite import Favorite
        results = (
            self.db.query(Favorite.event_id)
            .filter(Favorite.user_email == user_email)
            .all()
        )
        return [r[0] for r in results]

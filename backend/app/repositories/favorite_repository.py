from sqlalchemy.orm import Session
from typing import List

from app.models.favorite import Favorite


class FavoriteRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_user(self, user_email: str) -> List[Favorite]:
        return (
            self.db.query(Favorite)
            .filter(Favorite.user_email == user_email)
            .all()
        )

    def get_by_user_and_event(self, user_email: str, event_id: int) -> Favorite | None:
        return (
            self.db.query(Favorite)
            .filter(
                Favorite.user_email == user_email,
                Favorite.event_id == event_id,
            )
            .first()
        )

    def is_favorite(self, user_email: str, event_id: int) -> bool:
        return (
            self.db.query(Favorite)
            .filter(
                Favorite.user_email == user_email,
                Favorite.event_id == event_id,
            )
            .first()
            is not None
        )

    def add(self, event_id: int, user_email: str) -> Favorite:
        fav = Favorite(event_id=event_id, user_email=user_email)
        self.db.add(fav)
        self.db.commit()
        self.db.refresh(fav)
        return fav

    def remove(self, favorite: Favorite) -> None:
        self.db.delete(favorite)
        self.db.commit()

    def get_user_favorite_event_ids(self, user_email: str) -> List[int]:
        results = (
            self.db.query(Favorite.event_id)
            .filter(Favorite.user_email == user_email)
            .all()
        )
        return [r[0] for r in results]

from typing import List
from sqlalchemy.orm import Session

from app.repositories.favorite_repository import FavoriteRepository
from app.schemas.favorite import FavoriteResponse


class FavoriteService:
    def __init__(self, db: Session):
        self.repo = FavoriteRepository(db)

    def get_user_favorites(self, user_email: str) -> List[FavoriteResponse]:
        favs = self.repo.get_by_user(user_email)
        return [
            FavoriteResponse(
                id=f.id,
                event_id=f.event_id,
                user_email=f.user_email,
                created_at=f.created_at.isoformat() if f.created_at else None,
            )
            for f in favs
        ]

    def toggle(self, event_id: int, user_email: str) -> dict:
        existing = self.repo.get_by_user_and_event(user_email, event_id)
        if existing:
            self.repo.remove(existing)
            return {"success": True, "message": "Retiré des favoris", "is_favorite": False}
        else:
            self.repo.add(event_id, user_email)
            return {"success": True, "message": "Ajouté aux favoris", "is_favorite": True}

    def is_favorite(self, user_email: str, event_id: int) -> bool:
        return self.repo.is_favorite(user_email, event_id)

    def get_favorite_event_ids(self, user_email: str) -> List[int]:
        return self.repo.get_user_favorite_event_ids(user_email)

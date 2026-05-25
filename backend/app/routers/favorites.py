from typing import List
from fastapi import APIRouter, Depends, Header, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.favorite import FavoriteCreate, FavoriteResponse
from app.services.favorite_service import FavoriteService

router = APIRouter(prefix="/api/favorites", tags=["Favoris"])


def get_fav_service(db: Session = Depends(get_db)) -> FavoriteService:
    return FavoriteService(db)


@router.get("/", response_model=List[FavoriteResponse])
def get_favorites(
    user_email: str = Header(...),
    service: FavoriteService = Depends(get_fav_service),
):
    return service.get_user_favorites(user_email)


@router.get("/check/{event_id}")
def check_favorite(
    event_id: int,
    user_email: str = Header(...),
    service: FavoriteService = Depends(get_fav_service),
):
    return {"is_favorite": service.is_favorite(user_email, event_id)}


@router.post("/toggle")
def toggle_favorite(
    data: FavoriteCreate,
    user_email: str = Header(...),
    service: FavoriteService = Depends(get_fav_service),
):
    result = service.toggle(data.event_id, user_email)
    if not result["success"]:
        raise HTTPException(status_code=400, detail=result["message"])
    return result

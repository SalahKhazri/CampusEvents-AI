from pydantic import BaseModel


class FavoriteCreate(BaseModel):
    event_id: int


class FavoriteResponse(BaseModel):
    id: int
    event_id: int
    user_email: str
    created_at: str | None

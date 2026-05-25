from pydantic import BaseModel


class RegistrationCreate(BaseModel):
    event_id: int


class RegistrationResponse(BaseModel):
    id: int
    event_id: int
    user_email: str
    registered_at: str | None
    is_cancelled: int

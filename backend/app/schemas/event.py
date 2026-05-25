from datetime import datetime
from pydantic import BaseModel, field_validator


class EventCreate(BaseModel):
    title: str
    description: str
    category: str
    start_date_time: datetime
    end_date_time: datetime
    location_name: str
    location_address: str | None = None
    organizer_name: str
    capacity: int
    tags: str | None = None
    image_url: str | None = None

    @field_validator("title", "description", "category", "location_name", "organizer_name")
    @classmethod
    def check_not_empty(cls, v):
        if not v or not v.strip():
            raise ValueError("Ce champ ne peut pas être vide")
        return v.strip()

    @field_validator("capacity")
    @classmethod
    def check_positive_capacity(cls, v):
        if v <= 0:
            raise ValueError("La capacité doit être positive")
        return v

    @field_validator("end_date_time")
    @classmethod
    def check_end_after_start(cls, v, info):
        if "start_date_time" in info.data and v <= info.data["start_date_time"]:
            raise ValueError("La date de fin doit être après la date de début")
        return v


class EventUpdate(BaseModel):
    title: str | None = None
    description: str | None = None
    category: str | None = None
    start_date_time: datetime | None = None
    end_date_time: datetime | None = None
    location_name: str | None = None
    location_address: str | None = None
    organizer_name: str | None = None
    capacity: int | None = None
    tags: str | None = None
    image_url: str | None = None
    is_active: bool | None = None

    @field_validator("capacity")
    @classmethod
    def check_positive_capacity(cls, v):
        if v is not None and v <= 0:
            raise ValueError("La capacité doit être positive")
        return v

    @field_validator("end_date_time")
    @classmethod
    def check_end_after_start(cls, v, info):
        if v is not None and "start_date_time" in info.data and info.data["start_date_time"] is not None:
            if v <= info.data["start_date_time"]:
                raise ValueError("La date de fin doit être après la date de début")
        return v


class EventResponse(BaseModel):
    id: int
    title: str
    description: str
    category: str
    start_date_time: str
    end_date_time: str
    location_name: str
    location_address: str | None
    organizer_name: str
    capacity: int
    tags: str | None
    image_url: str | None
    is_active: bool
    created_at: str | None
    updated_at: str | None
    registration_count: int = 0

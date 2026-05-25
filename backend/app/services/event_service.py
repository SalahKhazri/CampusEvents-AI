from typing import List
from datetime import datetime
from sqlalchemy.orm import Session

from app.repositories.event_repository import EventRepository
from app.schemas.event import EventCreate, EventUpdate, EventResponse


class EventService:
    def __init__(self, db: Session):
        self.repo = EventRepository(db)

    def _to_response(self, event) -> EventResponse:
        count = self.repo.get_registration_count(event.id)
        return EventResponse(
            id=event.id,
            title=event.title,
            description=event.description,
            category=event.category,
            start_date_time=event.start_date_time.isoformat(),
            end_date_time=event.end_date_time.isoformat(),
            location_name=event.location_name,
            location_address=event.location_address,
            organizer_name=event.organizer_name,
            capacity=event.capacity,
            tags=event.tags,
            image_url=event.image_url,
            is_active=event.is_active,
            created_at=event.created_at.isoformat() if event.created_at else None,
            updated_at=event.updated_at.isoformat() if event.updated_at else None,
            registration_count=count,
        )

    def get_all(self, skip: int = 0, limit: int = 100) -> List[EventResponse]:
        events = self.repo.get_all(skip, limit)
        return [self._to_response(e) for e in events]

    def get_by_id(self, event_id: int) -> EventResponse | None:
        event = self.repo.get_by_id(event_id)
        if not event:
            return None
        return self._to_response(event)

    def create(self, data: EventCreate) -> EventResponse:
        event = self.repo.create(data.model_dump())
        return self._to_response(event)

    def update(self, event_id: int, data: EventUpdate) -> EventResponse | None:
        event = self.repo.get_by_id(event_id)
        if not event:
            return None
        update_data = {k: v for k, v in data.model_dump().items() if v is not None}
        event = self.repo.update(event, update_data)
        return self._to_response(event)

    def delete(self, event_id: int) -> bool:
        event = self.repo.get_by_id(event_id)
        if not event:
            return False
        self.repo.delete(event)
        return True

    def search(self, query: str, category: str | None = None) -> List[EventResponse]:
        events = self.repo.search(query, category)
        return [self._to_response(e) for e in events]

    def get_upcoming(self) -> List[EventResponse]:
        events = self.repo.get_upcoming()
        return [self._to_response(e) for e in events]

    def get_past(self) -> List[EventResponse]:
        events = self.repo.get_past()
        return [self._to_response(e) for e in events]

    def get_by_category(self, category: str) -> List[EventResponse]:
        events = self.repo.get_by_category(category)
        return [self._to_response(e) for e in events]

    def get_categories(self) -> List[str]:
        return self.repo.get_categories()

    def get_registration_count(self, event_id: int) -> int:
        return self.repo.get_registration_count(event_id)

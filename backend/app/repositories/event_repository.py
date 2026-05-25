from sqlalchemy.orm import Session
from sqlalchemy import desc
from datetime import datetime
from typing import List

from app.models.event import Event


class EventRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_all(self, skip: int = 0, limit: int = 100) -> List[Event]:
        return (
            self.db.query(Event)
            .filter(Event.is_active == True)
            .order_by(desc(Event.start_date_time))
            .offset(skip)
            .limit(limit)
            .all()
        )

    def get_by_id(self, event_id: int) -> Event | None:
        return self.db.query(Event).filter(Event.id == event_id).first()

    def create(self, data: dict) -> Event:
        event = Event(**data)
        self.db.add(event)
        self.db.commit()
        self.db.refresh(event)
        return event

    def update(self, event: Event, data: dict) -> Event:
        for key, value in data.items():
            if value is not None:
                setattr(event, key, value)
        event.updated_at = datetime.utcnow()
        self.db.commit()
        self.db.refresh(event)
        return event

    def delete(self, event: Event) -> None:
        event.is_active = False
        event.updated_at = datetime.utcnow()
        self.db.commit()

    def search(self, query: str, category: str | None = None) -> List[Event]:
        q = self.db.query(Event).filter(Event.is_active == True)
        q = q.filter(
            Event.title.ilike(f"%{query}%")
            | Event.description.ilike(f"%{query}%")
            | Event.tags.ilike(f"%{query}%")
            | Event.location_name.ilike(f"%{query}%")
        )
        if category:
            q = q.filter(Event.category == category)
        return q.order_by(desc(Event.start_date_time)).all()

    def get_upcoming(self, skip: int = 0, limit: int = 100) -> List[Event]:
        now = datetime.utcnow()
        return (
            self.db.query(Event)
            .filter(Event.is_active == True, Event.start_date_time >= now)
            .order_by(Event.start_date_time)
            .offset(skip)
            .limit(limit)
            .all()
        )

    def get_past(self, skip: int = 0, limit: int = 100) -> List[Event]:
        now = datetime.utcnow()
        return (
            self.db.query(Event)
            .filter(Event.is_active == True, Event.end_date_time < now)
            .order_by(desc(Event.start_date_time))
            .offset(skip)
            .limit(limit)
            .all()
        )

    def get_by_category(self, category: str) -> List[Event]:
        return (
            self.db.query(Event)
            .filter(Event.is_active == True, Event.category == category)
            .order_by(desc(Event.start_date_time))
            .all()
        )

    def get_categories(self) -> List[str]:
        results = (
            self.db.query(Event.category)
            .filter(Event.is_active == True)
            .distinct()
            .all()
        )
        return [r[0] for r in results if r[0]]

    def get_registration_count(self, event_id: int) -> int:
        from app.models.registration import Registration
        return (
            self.db.query(Registration)
            .filter(
                Registration.event_id == event_id,
                Registration.is_cancelled == 0,
            )
            .count()
        )

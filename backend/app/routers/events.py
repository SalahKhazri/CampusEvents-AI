from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.event import EventCreate, EventUpdate, EventResponse
from app.services.event_service import EventService

router = APIRouter(prefix="/api/events", tags=["Événements"])


def get_event_service(db: Session = Depends(get_db)) -> EventService:
    return EventService(db)


@router.get("/", response_model=List[EventResponse])
def list_events(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=200),
    service: EventService = Depends(get_event_service),
):
    return service.get_all(skip=skip, limit=limit)


@router.get("/upcoming", response_model=List[EventResponse])
def upcoming_events(service: EventService = Depends(get_event_service)):
    return service.get_upcoming()


@router.get("/past", response_model=List[EventResponse])
def past_events(service: EventService = Depends(get_event_service)):
    return service.get_past()


@router.get("/categories", response_model=List[str])
def get_categories(service: EventService = Depends(get_event_service)):
    return service.get_categories()


@router.get("/search", response_model=List[EventResponse])
def search_events(
    q: str = Query(..., min_length=1),
    category: Optional[str] = Query(None),
    service: EventService = Depends(get_event_service),
):
    return service.search(q, category)


@router.get("/category/{category}", response_model=List[EventResponse])
def events_by_category(
    category: str,
    service: EventService = Depends(get_event_service),
):
    return service.get_by_category(category)


@router.get("/{event_id}", response_model=EventResponse)
def get_event(
    event_id: int,
    service: EventService = Depends(get_event_service),
):
    event = service.get_by_id(event_id)
    if not event:
        raise HTTPException(status_code=404, detail="Événement introuvable")
    return event


@router.post("/", response_model=EventResponse, status_code=201)
def create_event(
    data: EventCreate,
    service: EventService = Depends(get_event_service),
):
    return service.create(data)


@router.put("/{event_id}", response_model=EventResponse)
def update_event(
    event_id: int,
    data: EventUpdate,
    service: EventService = Depends(get_event_service),
):
    event = service.update(event_id, data)
    if not event:
        raise HTTPException(status_code=404, detail="Événement introuvable")
    return event


@router.delete("/{event_id}", status_code=204)
def delete_event(
    event_id: int,
    service: EventService = Depends(get_event_service),
):
    if not service.delete(event_id):
        raise HTTPException(status_code=404, detail="Événement introuvable")

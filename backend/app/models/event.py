from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, DateTime, Boolean

from app.database import Base


class Event(Base):
    __tablename__ = "events"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    category = Column(String(100), nullable=False)
    start_date_time = Column(DateTime, nullable=False)
    end_date_time = Column(DateTime, nullable=False)
    location_name = Column(String(255), nullable=False)
    location_address = Column(String(500), nullable=True)
    organizer_name = Column(String(255), nullable=False)
    capacity = Column(Integer, nullable=False)
    tags = Column(String(500), nullable=True)
    image_url = Column(String(500), nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self):
        return {
            "id": self.id,
            "title": self.title,
            "description": self.description,
            "category": self.category,
            "start_date_time": self.start_date_time.isoformat(),
            "end_date_time": self.end_date_time.isoformat(),
            "location_name": self.location_name,
            "location_address": self.location_address,
            "organizer_name": self.organizer_name,
            "capacity": self.capacity,
            "tags": self.tags,
            "image_url": self.image_url,
            "is_active": self.is_active,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }

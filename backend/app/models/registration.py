from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, UniqueConstraint

from app.database import Base


class Registration(Base):
    __tablename__ = "registrations"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    event_id = Column(Integer, ForeignKey("events.id", ondelete="CASCADE"), nullable=False)
    user_email = Column(String(255), nullable=False)
    registered_at = Column(DateTime, default=datetime.utcnow)
    is_cancelled = Column(Integer, default=0)

    __table_args__ = (
        UniqueConstraint("event_id", "user_email", name="uq_event_user"),
    )

    def to_dict(self):
        return {
            "id": self.id,
            "event_id": self.event_id,
            "user_email": self.user_email,
            "registered_at": self.registered_at.isoformat() if self.registered_at else None,
            "is_cancelled": self.is_cancelled,
        }

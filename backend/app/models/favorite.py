from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, UniqueConstraint

from app.database import Base


class Favorite(Base):
    __tablename__ = "favorites"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    event_id = Column(Integer, ForeignKey("events.id", ondelete="CASCADE"), nullable=False)
    user_email = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    __table_args__ = (
        UniqueConstraint("event_id", "user_email", name="uq_fav_event_user"),
    )

    def to_dict(self):
        return {
            "id": self.id,
            "event_id": self.event_id,
            "user_email": self.user_email,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }

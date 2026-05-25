from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, DateTime

from app.database import Base


class LlmResult(Base):
    __tablename__ = "llm_results"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_email = Column(String(255), nullable=False)
    query_type = Column(String(50), nullable=False)
    query_text = Column(Text, nullable=False)
    response_text = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            "id": self.id,
            "user_email": self.user_email,
            "query_type": self.query_type,
            "query_text": self.query_text,
            "response_text": self.response_text,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }

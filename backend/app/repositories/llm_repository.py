from sqlalchemy.orm import Session
from typing import List

from app.models.llm_result import LlmResult


class LlmRepository:
    def __init__(self, db: Session):
        self.db = db

    def save_query(self, user_email: str, query_type: str, query_text: str, response_text: str) -> LlmResult:
        result = LlmResult(
            user_email=user_email,
            query_type=query_type,
            query_text=query_text,
            response_text=response_text,
        )
        self.db.add(result)
        self.db.commit()
        self.db.refresh(result)
        return result

    def get_history(self, user_email: str, limit: int = 20) -> List[LlmResult]:
        return (
            self.db.query(LlmResult)
            .filter(LlmResult.user_email == user_email)
            .order_by(LlmResult.created_at.desc())
            .limit(limit)
            .all()
        )

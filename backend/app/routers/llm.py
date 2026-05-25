from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.llm import LlmQueryRequest, LlmQueryResponse
from app.services.llm_service import LlmService

router = APIRouter(prefix="/api/llm", tags=["Assistant IA"])


def get_llm_service(db: Session = Depends(get_db)) -> LlmService:
    return LlmService(db)


@router.post("/query", response_model=LlmQueryResponse)
def process_llm_query(
    request: LlmQueryRequest,
    service: LlmService = Depends(get_llm_service),
):
    if request.query_type not in ["search", "recommendation", "planning", "qa"]:
        raise HTTPException(
            status_code=400,
            detail="Type de requête invalide. Choisir parmi: search, recommendation, planning, qa",
        )
    if not request.query_text.strip():
        raise HTTPException(status_code=400, detail="La requête ne peut pas être vide")
    return service.process_query(
        query_type=request.query_type,
        query_text=request.query_text,
        user_email=request.user_email,
    )

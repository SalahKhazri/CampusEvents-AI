from fastapi import APIRouter, HTTPException

from app.schemas.auth import LoginRequest, LoginResponse
from app.services.auth_service import AuthService

router = APIRouter(prefix="/api/auth", tags=["Authentification"])
auth_service = AuthService()


@router.post("/login", response_model=LoginResponse)
def login(request: LoginRequest):
    result = auth_service.login(request.email, request.password)
    if not result.success:
        raise HTTPException(status_code=401, detail=result.message)
    return result

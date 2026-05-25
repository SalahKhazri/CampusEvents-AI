from pydantic import BaseModel, EmailStr


class LoginRequest(BaseModel):
    email: str
    password: str


class UserInfo(BaseModel):
    email: str
    role: str
    name: str


class LoginResponse(BaseModel):
    success: bool
    message: str
    user: UserInfo | None = None

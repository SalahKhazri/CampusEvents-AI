from app.config import settings
from app.schemas.auth import LoginResponse, UserInfo


class AuthService:

    MOCK_USERS = {
        settings.ADMIN_EMAIL: {
            "password": settings.ADMIN_PASSWORD,
            "role": "admin",
            "name": "Admin Campus",
        },
        settings.STUDENT_EMAIL: {
            "password": settings.STUDENT_PASSWORD,
            "role": "student",
            "name": "Étudiant Test",
        },
    }

    def login(self, email: str, password: str) -> LoginResponse:
        user = self.MOCK_USERS.get(email)
        if not user:
            return LoginResponse(
                success=False,
                message="Email non trouvé",
            )
        if user["password"] != password:
            return LoginResponse(
                success=False,
                message="Mot de passe incorrect",
            )
        return LoginResponse(
            success=True,
            message="Connexion réussie",
            user=UserInfo(
                email=email,
                role=user["role"],
                name=user["name"],
            ),
        )

    def get_user_info(self, email: str) -> UserInfo | None:
        user = self.MOCK_USERS.get(email)
        if not user:
            return None
        return UserInfo(
            email=email,
            role=user["role"],
            name=user["name"],
        )

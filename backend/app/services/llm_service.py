import httpx
import json
from typing import List
from sqlalchemy.orm import Session

from app.config import settings
from app.repositories.event_repository import EventRepository
from app.repositories.registration_repository import RegistrationRepository
from app.repositories.favorite_repository import FavoriteRepository
from app.repositories.llm_repository import LlmRepository


class LlmService:
    def __init__(self, db: Session):
        self.db = db
        self.event_repo = EventRepository(db)
        self.reg_repo = RegistrationRepository(db)
        self.fav_repo = FavoriteRepository(db)
        self.llm_repo = LlmRepository(db)

    def _build_context(self, user_email: str) -> str:
        events = self.event_repo.get_all(limit=50)
        context_parts = ["Voici le catalogue des événements universitaires disponibles:"]
        for e in events:
            reg_count = self.event_repo.get_registration_count(e.id)
            context_parts.append(
                f"- ID:{e.id} | {e.title} | Catégorie: {e.category} | "
                f"Début: {e.start_date_time.strftime('%d/%m/%Y %H:%M')} | "
                f"Fin: {e.end_date_time.strftime('%d/%m/%Y %H:%M')} | "
                f"Lieu: {e.location_name} | Organisateur: {e.organizer_name} | "
                f"Capacité: {e.capacity} | Inscrits: {reg_count} | "
                f"Tags: {e.tags or 'N/A'}"
            )

        fav_ids = self.fav_repo.get_user_favorite_event_ids(user_email)
        if fav_ids:
            fav_events = [e for e in events if e.id in fav_ids]
            context_parts.append("\nÉvénements favoris de l'utilisateur:")
            for e in fav_events:
                context_parts.append(f"- {e.title} ({e.category})")

        reg_ids = [r.event_id for r in self.reg_repo.get_by_user(user_email)]
        if reg_ids:
            reg_events = [e for e in events if e.id in reg_ids]
            context_parts.append("\nÉvénements auxquels l'utilisateur est inscrit:")
            for e in reg_events:
                context_parts.append(f"- {e.title} ({e.category})")

        context = "\n".join(context_parts)
        if len(context) > settings.LLM_MAX_CONTEXT:
            context = context[:settings.LLM_MAX_CONTEXT]
        return context

    def _build_search_prompt(self, query: str, context: str) -> str:
        return f"""Tu es un assistant IA spécialisé dans les événements universitaires du campus.
Tu aides les étudiants à trouver des événements en langage naturel.

Contexte des événements disponibles:
{context}

Question de l'étudiant: {query}

Cherche dans le catalogue les événements qui correspondent à cette requête. 
Réponds en français de manière claire et structurée en listant les événements pertinents avec leurs détails (titre, date, lieu).
Si aucun événement ne correspond, propose des alternatives ou suggestions."""

    def _build_recommendation_prompt(self, query: str, context: str) -> str:
        return f"""Tu es un assistant IA spécialisé dans la recommandation d'événements universitaires.

Contexte des événements disponibles et des préférences de l'utilisateur:
{context}

Demande de recommandation: {query}

Basé sur les favoris et inscriptions de l'étudiant, recommande-lui des événements pertinents.
Explique pourquoi chaque recommandation est adaptée à son profil.
Réponds en français de manière amicale et personnalisée."""

    def _build_planning_prompt(self, query: str, context: str) -> str:
        return f"""Tu es un assistant IA spécialisé dans la planification d'emploi du temps pour les événements universitaires.

Contexte des événements disponibles:
{context}

Contrainte de planning de l'étudiant: {query}

Analyse les disponibilités de l'étudiant et propose un planning personnalisé d'événements qui ne conflictent pas avec ses contraintes.
Propose un ordre chronologique logique.
Réponds en français de manière structurée."""

    def _build_qa_prompt(self, query: str, context: str) -> str:
        return f"""Tu es un assistant IA expert en événements et activités universitaires.

Contexte complet du catalogue:
{context}

Question de l'étudiant: {query}

Réponds de manière détaillée et utile en te basant uniquement sur les informations du catalogue.
Si la question dépasse le cadre du catalogue, oriente l'étudiant vers les services universitaires appropriés.
Réponds en français."""

    def _call_ollama(self, prompt: str) -> str:
        payload = {
            "model": settings.OLLAMA_MODEL,
            "prompt": prompt,
            "stream": False,
        }
        try:
            with httpx.Client(timeout=60.0) as client:
                response = client.post(settings.OLLAMA_URL, json=payload)
                response.raise_for_status()
                data = response.json()
                return data.get("response", "Désolé, je n'ai pas pu générer une réponse.")
        except httpx.ConnectError:
            return "Erreur : Impossible de se connecter à Ollama. Vérifie qu'Ollama est bien lancé avec `ollama run llama3`."
        except httpx.TimeoutException:
            return "Erreur : La requête a pris trop de temps. Ollama est-il bien lancé ?"
        except Exception as e:
            return f"Erreur lors de l'appel à l'IA : {str(e)}"

    def process_query(self, query_type: str, query_text: str, user_email: str) -> dict:
        context = self._build_context(user_email)

        prompt_builders = {
            "search": self._build_search_prompt,
            "recommendation": self._build_recommendation_prompt,
            "planning": self._build_planning_prompt,
            "qa": self._build_qa_prompt,
        }

        builder = prompt_builders.get(query_type)
        if not builder:
            return {"success": False, "response": "Type de requête non supporté"}

        prompt = builder(query_text, context)
        response_text = self._call_ollama(prompt)

        self.llm_repo.save_query(user_email, query_type, query_text, response_text)

        return {"success": True, "response": response_text}

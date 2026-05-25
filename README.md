# CampusEvents AI 🎓

Application mobile universitaire de gestion d'événements avec assistant IA intégré (Llama 3).

## 📋 Table des matières

1. [Stack Technique](#-stack-technique)
2. [Architecture](#-architecture)
3. [Installation](#-installation)
4. [Configuration Ollama](#-configuration-ollama)
5. [Lancement](#-lancement)
6. [API Endpoints](#-api-endpoints)
7. [Comptes de démonstration](#-comptes-de-démonstration)
8. [Fonctionnalités](#-fonctionnalités)
9. [Structure du Projet](#-structure-du-projet)

## 🚀 Stack Technique

- **Frontend Mobile**: Flutter + Riverpod + GoRouter + Dio + Material 3
- **Backend API**: FastAPI + SQLAlchemy + Pydantic
- **Base de données**: SQLite
- **LLM**: Ollama + Llama 3

## 🏗 Architecture

### Backend (Clean Architecture en couches)

```
backend/
├── app/
│   ├── models/         # Modèles SQLAlchemy
│   ├── schemas/        # Schémas Pydantic (validation)
│   ├── repositories/   # Accès aux données (CRUD)
│   ├── services/       # Logique métier
│   ├── routers/        # Endpoints API REST
│   ├── config.py       # Configuration
│   ├── database.py     # Connexion SQLite
│   ├── seed.py         # Données de démo
│   └── main.py        # Point d'entrée FastAPI
```

### Frontend (Feature-based Architecture)

```
frontend/lib/
├── core/               # Constantes, thème, helpers
├── models/             # Modèles de données
├── services/           # API client, session
├── providers/          # Riverpod state management
├── routes/             # GoRouter configuration
├── widgets/            # Composants réutilisables
└── features/           # Modules fonctionnels
    ├── auth/           # Connexion
    ├── admin/          # CRUD événements
    ├── student/        # Catalogue, favoris, inscriptions
    └── ai_assistant/   # Assistant IA 4 modules
```

## 📦 Installation

### Prérequis

- Python 3.10+
- Flutter 3.16+ (optionnel — peut utiliser Docker)
- Docker Desktop (optionnel — pour Flutter sans SDK local)
- Ollama (pour l'assistant IA)

### Backend

```bash
cd backend
python -m venv venv

# Windows
venv\Scripts\activate

# macOS/Linux
source venv/bin/activate

pip install -r requirements.txt
python run.py
```

### Frontend (2 options)

#### Option 1 : Flutter SDK local

```bash
cd frontend
flutter pub get
flutter run
```

#### Option 2 : Docker (sans Flutter SDK)

```bash
cd frontend
docker compose up
# Accès : http://localhost:3000
```

> Hot reload : appuyez sur `R` dans le terminal Docker.

## 🤖 Configuration Ollama

1. Installer Ollama : https://ollama.ai
2. Télécharger le modèle Llama 3 :

```bash
ollama pull llama3
```

3. Vérifier que Ollama tourne :

```bash
ollama run llama3
```

4. L'API sera accessible sur : `http://localhost:11434/api/generate`

## 🐳 Docker (Frontend Flutter uniquement)

Le backend FastAPI et Ollama restent installés **localement**. Seul Flutter tourne dans Docker.

### Architecture Docker

```
+------------------+         +------------------+         +------------------+
|  Navigateur      |  :3000  |  Conteneur       |         |  Hôte (local)    |
|  localhost:3000  | <-----> |  Flutter Web     |         |  FastAPI :8000   |
|  (sur le PC)     |         |  (Docker)        |         |  Ollama :11434   |
+------------------+         +------------------+         +------------------+
                                      |                           |
                                      +--- host.docker.internal --+
                                          (Docker → services locaux)
```

### Démarrer avec Docker

```bash
# 1. Démarrer le backend (local)
cd backend
python run.py

# 2. Démarrer Ollama (local)
ollama run llama3

# 3. Démarrer Flutter dans Docker (dans un autre terminal)
cd frontend
docker compose up
```

L'application est accessible sur : **http://localhost:3000**

### Hot Reload

Pour recharger l'application sans rebuild :

1. Garder le terminal Docker ouvert
2. Appuyer sur la touche **`R`** (majuscule) dans le terminal
3. Les modifications de code sont détectées via le volume monté

### Commandes Docker utiles

```bash
# Démarrer en arrière-plan
docker compose up -d

# Voir les logs
docker compose logs -f

# Arrêter
docker compose down

# Rebuild complet (après modifications du Dockerfile)
docker compose build --no-cache
docker compose up

# Nettoyer tout
docker compose down
docker container prune -f
docker image prune -f
```

### Scripts pratiques (Windows)

```bash
cd frontend
scripts\docker-dev.bat     # Build + démarrage avec logs
scripts\docker-clean.bat   # Nettoyage + rebuild frais
```


## 📡 API Endpoints

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | `/api/auth/login` | Connexion |
| GET | `/api/events/` | Liste des événements |
| GET | `/api/events/upcoming` | Événements à venir |
| GET | `/api/events/past` | Événements passés |
| GET | `/api/events/search?q=` | Recherche textuelle |
| GET | `/api/events/category/{cat}` | Filtre par catégorie |
| GET | `/api/events/categories` | Liste des catégories |
| GET | `/api/events/{id}` | Détail d'un événement |
| POST | `/api/events/` | Créer un événement (admin) |
| PUT | `/api/events/{id}` | Modifier un événement (admin) |
| DELETE | `/api/events/{id}` | Supprimer un événement (admin) |
| GET | `/api/favorites/` | Liste des favoris |
| POST | `/api/favorites/toggle` | Ajouter/Retirer favori |
| GET | `/api/registrations/` | Liste des inscriptions |
| POST | `/api/registrations/` | S'inscrire |
| DELETE | `/api/registrations/{id}` | Annuler inscription |
| POST | `/api/llm/query` | Requête assistant IA |

## 👥 Comptes de démonstration

| Rôle | Email | Mot de passe |
|------|-------|-------------|
| Admin | admin@campus.ma | admin123 |
| Étudiant | etudiant@campus.ma | etudiant123 |

## ✨ Fonctionnalités

### Administrateur
- CRUD complet des événements
- Validation des champs (date, capacité, etc.)
- Interface Material 3 moderne

### Étudiant
- Catalogue d'événements avec recherche et filtres
- Favoris persistants
- Inscription aux événements
- Détail complet des événements

### Assistant IA (Llama 3)
1. **Recherche en langage naturel** : "Je cherche un workshop IA ce weekend"
2. **Recommandation personnalisée** : basée sur favoris et inscriptions
3. **Planification intelligente** : planning selon contraintes
4. **Questions/Réponses** : sur tout le catalogue

## 📁 Structure du Projet

```
CampusEvents AI/
├── backend/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py
│   │   ├── config.py
│   │   ├── database.py
│   │   ├── seed.py
│   │   ├── models/
│   │   ├── schemas/
│   │   ├── routers/
│   │   ├── services/
│   │   └── repositories/
│   ├── requirements.txt
│   └── run.py
├── frontend/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/
│   │   ├── models/
│   │   ├── services/
│   │   ├── providers/
│   │   ├── routes/
│   │   ├── widgets/
│   │   └── features/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── .dockerignore
│   ├── scripts/
│   │   ├── docker-dev.bat
│   │   └── docker-clean.bat
│   ├── pubspec.yaml
│   └── assets/
├── README.md
├── setup.bat
└── run_all.bat
```

## 🛠 Scripts Utiles

### Windows
```bash
setup.bat       # Installe toutes les dépendances
run_all.bat     # Lance backend + frontend
```

### macOS/Linux
```bash
chmod +x setup.sh
./setup.sh
```

---

**Projet universitaire - LSI S4 - CampusEvents AI**

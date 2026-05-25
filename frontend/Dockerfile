# =============================================================================
# CampusEvents AI - Flutter Web Dockerfile
# =============================================================================
# Utilise l'image Flutter officielle maintenue par Cirrus Labs
# Inclut Dart, Flutter SDK, Chrome pour testing, et outils web
# =============================================================================

FROM ghcr.io/cirruslabs/flutter:stable

# =============================================================================
# ENVIRONMENT
# =============================================================================
ENV FLUTTER_WEB_PORT=3000
ENV FLUTTER_WEB_HOSTNAME=0.0.0.0

# =============================================================================
# Installer les dépendances système nécessaires
# =============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# =============================================================================
# Définir le répertoire de travail
# =============================================================================
WORKDIR /app

# =============================================================================
# Copier uniquement les fichiers de dépendances pour le cache Docker
# =============================================================================
COPY pubspec.yaml pubspec.lock* ./

# =============================================================================
# Installer les dépendances Dart/Flutter (en cache tant que pubspec ne change pas)
# =============================================================================
RUN flutter pub get

# =============================================================================
# Copier le code source
# =============================================================================
COPY . .

# =============================================================================
# Exécuter à nouveau pub get pour s'assurer que tout est à jour
# =============================================================================
RUN flutter pub get

# =============================================================================
# Activer Flutter Web
# =============================================================================
RUN flutter config --enable-web

# =============================================================================
# Vérifier la configuration Flutter
# =============================================================================
RUN flutter doctor

# =============================================================================
# Exposer le port du serveur web
# =============================================================================
EXPOSE ${FLUTTER_WEB_PORT}

# =============================================================================
# Commande par défaut : lancer le serveur web Flutter avec hot reload
# - flutter run -d web-server : utilise le device web-server (hot reload via R)
# - --web-port : port d'écoute
# - --web-hostname : écouter sur toutes les interfaces (nécessaire pour Docker)
# =============================================================================
CMD flutter run -d web-server \
    --web-port ${FLUTTER_WEB_PORT} \
    --web-hostname ${FLUTTER_WEB_HOSTNAME}

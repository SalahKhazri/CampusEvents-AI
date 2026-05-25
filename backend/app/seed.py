from datetime import datetime, timedelta
from app.database import SessionLocal
from app.models.event import Event


def seed_database():
    db = SessionLocal()
    try:
        existing = db.query(Event).first()
        if existing:
            return

        now = datetime.utcnow()

        events_data = [
            {
                "title": "Introduction à l'Intelligence Artificielle",
                "description": "Un atelier interactif pour découvrir les bases de l'IA, du machine learning et du deep learning. Ouvert à tous les étudiants, aucun prérequis nécessaire.",
                "category": "Atelier",
                "start_date_time": now + timedelta(days=2),
                "end_date_time": now + timedelta(days=2, hours=3),
                "location_name": "Amphi A",
                "location_address": "Bâtiment Principal, 1er étage",
                "organizer_name": "Département Informatique",
                "capacity": 100,
                "tags": "IA, machine learning, deep learning, atelier",
                "image_url": None,
            },
            {
                "title": "Hackathon Data Science 2026",
                "description": "Competition de data science sur 48h. Formez vos équipes et résolvez des problèmes réels avec les données. Prix pour les 3 meilleures équipes.",
                "category": "Compétition",
                "start_date_time": now + timedelta(days=5),
                "end_date_time": now + timedelta(days=7),
                "location_name": "Lab Info 3",
                "location_address": "Bâtiment Sciences, Rez-de-chaussée",
                "organizer_name": "Club Data Science",
                "capacity": 60,
                "tags": "data science, hackathon, competition, python",
                "image_url": None,
            },
            {
                "title": "Conférence : Carrières dans la Tech",
                "description": "Des professionnels du secteur tech partagent leur parcours et conseils pour débuter une carrière dans la technologie. Networking après la conférence.",
                "category": "Conférence",
                "start_date_time": now + timedelta(days=10),
                "end_date_time": now + timedelta(days=10, hours=4),
                "location_name": "Grand Amphi",
                "location_address": "Bâtiment Administratif",
                "organizer_name": "Service Carrières",
                "capacity": 200,
                "tags": "carrière, tech, conférence, networking",
                "image_url": None,
            },
            {
                "title": "Workshop Développement Mobile Flutter",
                "description": "Apprenez à construire une application mobile complète avec Flutter et Dart. De zéro à une app déployée en 2 jours.",
                "category": "Atelier",
                "start_date_time": now + timedelta(days=3),
                "end_date_time": now + timedelta(days=4),
                "location_name": "Salle TP 5",
                "location_address": "Bâtiment Informatique, 2ème étage",
                "organizer_name": "Club Dev Mobile",
                "capacity": 30,
                "tags": "flutter, dart, mobile, workshop",
                "image_url": None,
            },
            {
                "title": "Soirée Culturelle Internationale",
                "description": "Venez découvrir et partager les cultures du monde à travers la musique, la danse et la gastronomie. Chaque étudiant peut présenter son pays.",
                "category": "Culturel",
                "start_date_time": now + timedelta(days=15),
                "end_date_time": now + timedelta(days=15, hours=5),
                "location_name": "Espace Polyvalent",
                "location_address": "Campus Centre",
                "organizer_name": "Bureau des Étudiants",
                "capacity": 300,
                "tags": "culture, international, soirée, musique",
                "image_url": None,
            },
            {
                "title": "Formation Cybersécurité niveau 1",
                "description": "Initiation à la cybersécurité : reconnaissance des menaces, bonnes pratiques, et outils de base pour sécuriser vos données.",
                "category": "Formation",
                "start_date_time": now + timedelta(days=7),
                "end_date_time": now + timedelta(days=7, hours=6),
                "location_name": "Lab Sécurité",
                "location_address": "Bâtiment Sciences, 3ème étage",
                "organizer_name": "Club Cyber",
                "capacity": 40,
                "tags": "cybersécurité, formation, sécurité, hacking",
                "image_url": None,
            },
            {
                "title": "Tournoi de Programmation",
                "description": "Compétition de programmation algorithmique. Résolvez des problèmes complexes en équipe. Durée : 4 heures.",
                "category": "Compétition",
                "start_date_time": now + timedelta(days=12),
                "end_date_time": now + timedelta(days=12, hours=4),
                "location_name": "Salle TP 8",
                "location_address": "Bâtiment Informatique, 1er étage",
                "organizer_name": "Club Algorithmique",
                "capacity": 50,
                "tags": "programmation, algorithme, compétition, équipe",
                "image_url": None,
            },
            {
                "title": "Atelier CV et Lettre de Motivation",
                "description": "Apprenez à rédiger un CV percutant et une lettre de motivation qui fera la différence. Relecture personnalisée par des professionnels RH.",
                "category": "Atelier",
                "start_date_time": now + timedelta(days=20),
                "end_date_time": now + timedelta(days=20, hours=3),
                "location_name": "Salle 210",
                "location_address": "Bâtiment Administratif, 2ème étage",
                "organizer_name": "Service Carrières",
                "capacity": 25,
                "tags": "CV, lettre de motivation, carrière, emploi",
                "image_url": None,
            },
        ]

        for event_data in events_data:
            event = Event(**event_data)
            db.add(event)

        db.commit()
        print(" Base de données initialisée avec des événements de démonstration.")
    except Exception as e:
        print(f"Erreur lors du seed : {e}")
        db.rollback()
    finally:
        db.close()

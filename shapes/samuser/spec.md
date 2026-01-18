# Spec: samuser

## Contexte

L'application `dessousaine` dispose déjà d'un module `cine_die` qui agrège les programmes cinéma de plusieurs cinémas strasbourgeois via du scraping HTML (Floki).

L'utilisateur souhaite une fonctionnalité similaire pour les **events des musées de Strasbourg**.

## Objectif

Créer une LiveView nommée "samuser" qui :
- Affiche les events en cours des musées de Strasbourg
- Permet de filtrer par musée
- Fournit pour chaque event : titre, date (string), tag de type de visite, photo, URL

L'UI doit ressembler au design Lovable fourni (image #1) :
- Header "Expos Strasbourg" avec sous-titre
- Barre de filtres par musée (tabs)
- Compteur d'events
- Grille de cards avec image, nom du musée, titre de l'event, dates
- **Badge rouge** si une event n'a pas de date (pour alerter l'utilisateur)

## Contraintes

- **LiveView** dans `lib/dessousaine_web/live/samuser_live.ex` et `.html.heex`
- **Code backend** dans `lib/samuser/`
- **Architecture inspirée de `cine_die`** mais **isolée** :
  - Un provider = un musée
  - Autant de providers que de musées
  - Behaviour commun pour les providers samuser (pas de partage avec cinedie)
- **Utiliser Floki** pour le scraping HTML
- **Tests** obligatoires pour chaque provider (même pattern que `test/dessousaine/cine_die/providers/`)

## Données à extraire par event

| Champ | Obligatoire | Source HTML | Notes |
|-------|-------------|-------------|-------|
| `title` | **Oui** | Dans `swiper-slide` | Titre de l'event |
| `date` | Non | Dans `swiper-slide` | String brute. Si absent → `nil` + badge rouge UI |
| `tag` | Non | Classe `visit` | Type de visite (optionnel) |
| `photo_url` | Non | Dans `a.event-thumbnail` | Image de l'event |
| `url` | Non | Dans `a.event-thumbnail` | Lien vers la page de l'event |

## Hypothèses

- Tous les musées de Strasbourg utilisent la même structure HTML (classe `slider` > `swiper-slide` par event)
- Le site https://www.musees.strasbourg.eu/ a une structure stable
- Les informations à extraire sont disponibles dans le DOM (pas de JS dynamique)

## Inconnues résolues

- [x] Nombre exact de musées à supporter initialement ? → On commence avec museezoo
- [x] Le tag "visit" est-il présent sur tous les musées ? → Optionnel
- [x] Y a-t-il des events sans dates ? → Oui, possible. Si nil → badge rouge UI

## Hors scope

- **Pas de vue agenda** - on ne veut pas savoir quel jour les events sont disponibles (c'est le rôle du site du musée)
- **Pas de descriptif détaillé** - juste les infos essentielles
- LLM pour parser des structures HTML volatiles (les musées de Strasbourg ont la même structure selon le sketch)

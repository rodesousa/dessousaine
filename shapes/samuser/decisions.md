# Décisions: samuser

## Décisions prises

### D001 - Architecture inspirée de cine_die mais isolée
**Date**: 2026-01-18
**Contexte**: Comment structurer le code backend
**Décision**: Suivre le pattern de `lib/dessousaine/cine_die/` mais **isoler complètement** la logique
- Un behaviour `Provider` propre à samuser (pas de partage avec cinedie)
- Un module provider par musée
- Utiliser Floki pour le scraping
**Raison**: Éviter le couplage entre les deux fonctionnalités

### D002 - Date en string optionnelle
**Date**: 2026-01-18
**Contexte**: Comment stocker les dates d'event
**Décision**: Garder la date sous forme de string brute, sans parsing. Si absente → `nil`
**Raison**: Éviter la complexité du parsing de formats variés ("15 août 2024 — 31 janv. 2025", etc.)

### D003 - Emplacement du code
**Date**: 2026-01-18
**Contexte**: Où placer le code
**Décision**:
- Backend: `lib/samuser/`
- LiveView: `lib/dessousaine_web/live/samuser_live.ex` et `.html.heex`

### D004 - Pas de vue agenda
**Date**: 2026-01-18
**Contexte**: Faut-il afficher les jours d'ouverture ?
**Décision**: Non. Ce n'est pas le besoin. C'est le rôle du site du musée.

### D005 - Champs obligatoires vs optionnels
**Date**: 2026-01-18
**Contexte**: Quels champs sont requis pour une event ?
**Décision**:
- **Obligatoire**: `title`
- **Optionnel**: `date`, `tag`, `photo_url`, `url`

### D006 - Badge rouge pour dates manquantes
**Date**: 2026-01-18
**Contexte**: Comment gérer les events sans date dans l'UI ?
**Décision**: Afficher un badge rouge d'alerte ("Date non disponible" ou similaire)
**Raison**: Alerter l'utilisateur que l'info est incomplète

### D007 - Ajout photo et URL
**Date**: 2026-01-18
**Contexte**: Quelles données supplémentaires extraire ?
**Décision**: Extraire `photo_url` et `url` depuis `a.event-thumbnail`

## Options rejetées

### R001 - Utiliser un LLM pour parser le HTML
**Contexte**: Les structures HTML des musées pourraient varier
**Rejet**: Le site musees.strasbourg.eu a la même structure pour tous les musées. Floki suffit.

### R002 - Partager le behaviour Provider avec cinedie
**Contexte**: Réutiliser le code existant
**Rejet**: Garder les deux domaines isolés pour éviter le couplage

### D008 - Renommage exhibitions → events
**Date**: 2026-01-18
**Contexte**: "Exhibitions" est anglais, les musées listent aussi concerts, visites, ateliers
**Décision**: Utiliser `events` au lieu de `exhibitions`
**Impact**: Renommer modules et clés lors de la reprise

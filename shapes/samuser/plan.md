# Plan: samuser

> Le MODE SHAPE ne complète pas le plan, il vérifie uniquement sa cohérence avec `spec.md`.

## Structure envisagée (à valider)

```
lib/
├── samuser/
│   ├── events.ex           # Contexte (équivalent de showtimes.ex)
│   ├── events/
│   │   └── event_data.ex   # Schema de validation des données
│   ├── providers/
│   │   ├── provider.ex          # Behaviour commun (isolé de cinedie)
│   │   └── musee_zoo.ex         # Premier provider (musée zoologique)
│   └── workers/
│       └── musee_zoo_worker.ex  # Worker Oban pour scraping
├── dessousaine_web/
│   └── live/
│       ├── samuser_live.ex      # LiveView
│       └── samuser_live.html.heex
test/
└── samuser/
    └── providers/
        └── musee_zoo_test.exs   # Tests du provider
```

## Données à extraire par event

| Champ | Obligatoire | Source HTML | Notes |
|-------|-------------|-------------|-------|
| `title` | **Oui** | Dans `swiper-slide` | Titre de l'eventsition |
| `date` | Non | Dans `swiper-slide` | String brute. Si absent → `nil` |
| `tag` | Non | Classe `visit` | Type de visite |
| `photo_url` | Non | `a.event-thumbnail img` | Image de l'event |
| `url` | Non | `a.event-thumbnail[href]` | Lien vers la page de l'event |

## Premier provider: museezoo

- URL: https://www.musees.strasbourg.eu/web/musees/musee-zoologique
- Sélecteur principal: `.slider .swiper-slide`
- Sélecteur lien/image: `a.event-thumbnail`

## UI: Gestion des dates manquantes

Si une event a `date: nil`, afficher un badge rouge avec un message du type :
- "Date non disponible"
- ou icône d'alerte

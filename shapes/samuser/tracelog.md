# Tracelog: samuser

## [2026-01-18 14:00] CRÉER 🤖 - Initialisation du SHAPE

**Contexte**: Demande utilisateur de créer une application "samuser" pour afficher les events des musées de Strasbourg
**Fichiers modifiés**: README.md, spec.md, plan.md, todos.md, decisions.md, tracelog.md
**Détail**:
- Création de la structure complète du SHAPE
- Analyse du pattern existant `cine_die` pour comprendre l'architecture
- Documentation des contraintes et décisions initiales
- Premier provider identifié : museezoo (musée zoologique)
- Sélecteurs HTML identifiés : `.slider`, `.swiper-slide`, `.visit`

## [2026-01-18 14:15] CLARIFIER 👤 - Retours utilisateur sur spec

**Contexte**: Clarifications demandées par l'utilisateur
**Fichiers modifiés**: spec.md, plan.md, decisions.md, todos.md
**Détail**:
- LiveView confirmée dans `lib/dessousaine_web/live/samuser_live.*`
- Logique provider **isolée** de cinedie (pas de partage de code)
- Champs obligatoires: uniquement `title`
- Champs optionnels: `date`, `tag`, `photo_url`, `url`
- Ajout de `photo_url` et `url` via `a.event-thumbnail`
- Si `date` est `nil` → badge rouge dans l'UI
- Nouvelles décisions: D005, D006, D007
- Option rejetée: R002 (partage behaviour avec cinedie)

## [2026-01-18 14:30] PROMOUVOIR - SHAPE pret pour implementation

**Contexte**: Toutes les clarifications ont ete apportees
**Fichiers modifies**: README.md
**Detail**:
- Statut passe de CLARIFYING a READY
- Lancement du MODE LEAD pour orchestrer l'implementation

## [2026-01-18 15:00] DISPATCH - Lancement implementation backend

**Contexte**: Lead technique demarre l'orchestration
**Detail**:
- Analyse du pattern cine_die terminee
- WebFetch non disponible - utilisation des selecteurs de la spec
- Selecteurs HTML: `.slider .swiper-slide`, `a.event-thumbnail`, `.visit`
- Taches decoupees: 9 taches identifiees
- Lancement T1: Creer le behaviour provider.ex

## [2026-01-18 15:30] SYNC 🧑‍💻 - Lead bloqué sur permissions

**Contexte**: Agent background sans accès aux permissions interactives
**Problème**:
- `WebFetch` bloqué → impossible de valider la structure HTML du musée
- `Bash` bloqué → impossible de lancer `mix compile` et `mix test`

**Travail accompli malgré le blocage**:
- ✅ `lib/samuser/providers/provider.ex` créé
- ✅ `lib/samuser/providers/musee_zoo.ex` créé
- ✅ `lib/samuser/exhibitions/exhibition_data.ex` créé
- ✅ `lib/samuser/exhibitions.ex` créé
- ✅ `test/samuser/providers/musee_zoo_test.exs` créé
- ✅ `lib/dessousaine_web/live/samuser_live.ex` créé
- ✅ `lib/dessousaine_web/live/samuser_live.html.heex` créé

**Actions requises** (hors agent):
- [ ] Lancer `mix compile` pour vérifier la syntaxe
- [ ] Lancer `mix test test/samuser/` pour valider le provider
- [ ] Vérifier les sélecteurs HTML avec WebFetch sur https://www.musees.strasbourg.eu/web/musees/musee-zoologique

**Statut**: Lead arrêté - reprise manuelle nécessaire

## [2026-01-18 15:35] IMPL 🤖 - Validation compilation et tests

**Contexte**: Reprise manuelle après arrêt du Lead
**Résultat**:
- ✅ `mix compile` - OK
- ✅ `mix test test/samuser/` - 6 tests, 0 failures

**Statut**: Backend validé

## [2026-01-18 15:40] VALIDER 🤖 - Structure HTML et scraping vérifié

**Contexte**: Vérification des sélecteurs HTML sur le site réel
**Découverte**:
- Les sélecteurs `.slider`, `.swiper-slide`, `.visit`, `a.event-thumbnail` ne sont PAS présents
- Mais le provider fonctionne grâce aux sélecteurs génériques de fallback (`h2`, `h3`, `.date`, `.tag`)

**Résultat scraping réel** (9 eventsitions trouvées):
```
- Info affluence – Musée Zoologique | date: 04/11/2025
- Nocturne étudiante : Parures et parades | date: Le 05 février 2026
- Petites merveilles | date: Du 24 octobre 2025 au 20 février 2026 | tag: Atelier
- Autour du Rhin : biodiversité et environnement | date: Le 25 janvier 2026 | tag: Visite
- Précieux Blaschka | date: Du 07 décembre 2025 au 01 février 2026 | tag: Visite
- Animaux totem | date: Du 19 novembre 2025 au 21 janvier 2026 | tag: Visite
- (Re)découverte du musée | date: Du 15 octobre 2025 au 18 février 2026 | tag: Visite
- À la découverte des Chefs-d'œuvres des Musées de Strasbourg | date: Publié le 3 décembre 2025
- Programme septembre 2025 - février 2026 dans les Musées | date: Publié le 26 août 2025
```

**Statut**: Scraping fonctionnel

## [2026-01-18 15:45] SYNC 🤖 - LEAD TERMINÉ

**Contexte**: Vérification finale de l'implémentation
**Résultat**:
- ✅ Backend complet (`lib/samuser/`)
- ✅ Tests passent (6 tests, 0 failures)
- ✅ LiveView implémentée avec design demandé
- ✅ Badge rouge pour dates manquantes (lignes 116-119 du template)
- ✅ Scraping fonctionnel (9 events trouvées)

**Statut**: SHAPE samuser prêt pour clôture PO

## [2026-01-18 16:00] ANALYZE 📋 - Rétrospective session

**Contexte**: Fin de session MODE LEAD
**Fichier**: analyse_0.md
**Points clés**:
- Lead bloqué sur permissions Bash/WebFetch (agents background)
- Sélecteurs HTML de la spec incorrects mais fallbacks ont fonctionné
- Suggestion principale: fichier `.claude/settings.local.json` pour pré-approuver les commandes
- Suggestion secondaire: documenter les limitations agents background dans lead_raw.md

## [2026-01-18 16:15] FEEDBACK 👤 - Retours UI

**Contexte**: Retours utilisateur sur le design de la LiveView
**Fichiers modifies**: samuser_live.html.heex
**Changements**:
- Fond blanc #fdfdfe (au lieu de gray-900)
- Couleur secondaire #f25434 (au lieu de emerald)
- Bouton "Voir plus" plus gros (pleine largeur, py-3)
- Titre de l'event en premier, plus gros (text-xl font-bold)
- Nom du musee plus petit, apres le titre (text-xs)
- Tag superpose sur l'image en haut a gauche (absolute top-3 left-3)

## [2026-01-18 17:00] FEEDBACK 👤 - Probleme majeur: pas de stockage DB

**Contexte**: L'utilisateur a demande "comme cinedie" mais le Lead n'a pas implemente le stockage en base de donnees
**Probleme**:
- cinedie a `WeeklySchedule` en DB avec Ecto
- samuser n'a PAS de stockage DB - fetch direct a chaque refresh
- Pas de `inserted_at` / `updated_at`
- Pas de persistence des donnees

**Impact**: Impossible de trier par date d'ajout, pas d'historique

**Action requise**:
- Creer un schema Ecto `Event` (comme `WeeklySchedule`)
- Creer une migration
- Modifier `Events` context pour upsert en DB
- Ajouter tri par `inserted_at`

**Statut**: FEATURE EN PAUSE - correction DB requise

## [2026-01-18 17:15] DECIDER 👤 - Renommage exhibitions → events

**Contexte**: "Exhibitions" est anglais, et les musees listent aussi concerts, visites, ateliers
**Decision**: Renommer `exhibitions` en `events` partout
**Fichiers modifies**: spec.md, plan.md, todos.md, decisions.md, tracelog.md
**Impact sur le code** (a faire lors de la reprise):
- `Samuser.Exhibitions` → `Samuser.Events`
- `ExhibitionData` → `EventData`
- `exhibitions` keys → `events`

## [2026-01-18 XX:XX] ANALYZE 🧑‍💻 - Reprise Lead

**Contexte**: Reprise du SHAPE après pause
**Fichiers lus**: spec.md, plan.md, decisions.md, todos.md, tracelog.md
**Code analysé**:
- `lib/samuser/exhibitions.ex` - context actuel (fetch direct, pas de DB)
- `lib/samuser/exhibitions/exhibition_data.ex` - validation embedded schema
- `lib/dessousaine/cine_die/showtimes.ex` - pattern reference (upsert DB)
- `lib/dessousaine/cine_die/showtimes/weekly_schedule.ex` - schema Ecto reference

**Patterns identifies**:
- cine_die utilise `WeeklySchedule` schema + JSONB pour `showtimes`
- `upsert_schedule/2` avec `on_conflict: {:replace, [...]}` pour éviter doublons
- PubSub pour notifier les LiveViews des mises à jour

**Tâches découpées**:
1. Renommer exhibitions → events (D008)
2. Créer schema `Samuser.Events.Event` (inspiré de `WeeklySchedule`)
3. Créer migration `create_samuser_events`
4. Modifier `Events` context pour upsert DB + PubSub

**Statut**: Prêt pour dispatch Dev

## [2026-01-18 XX:XX] DECIDER 👤 - Choix structure DB

**Contexte**: Deux approches possibles pour le stockage DB
**Options présentées**:
1. Un event par ligne (table classique) - tri facile par `inserted_at`
2. Events groupés par provider (comme `WeeklySchedule`) - pattern cohérent avec cine_die

**Décision utilisateur**: Approche 1 - Un event par ligne
**Fichiers créés**: `lib/samuser/events/event.ex`
**Schema**:
- `provider` (enum): museezoo, aubette, tomi_ungerer, etc.
- `title`, `date`, `tag`, `photo_url`, `url`, `museum_name` (strings)
- `checksum` (SHA256 du contenu pour détecter les doublons)
- `timestamps` (inserted_at, updated_at)
- Unique constraint sur `[:provider, :checksum]`

**Statut**: Schema créé, migration à créer

## [2026-01-18 12:42] IMPL 🤖 - Stockage DB implémenté

**Contexte**: Implémentation complète du stockage DB
**Fichiers créés/modifiés**:
- `lib/samuser/events/event.ex` - Schema Ecto avec checksum
- `priv/repo/migrations/20260118113422_create_samuser_events.exs` - Migration
- `lib/samuser/events.ex` - Context avec upsert, sync_all, PubSub
- `lib/dessousaine_web/live/samuser_live.ex` - LiveView avec subscribe PubSub

**Fonctionnalités ajoutées**:
- `Events.list_all/0` - Liste depuis DB triée par `inserted_at` desc
- `Events.sync_provider/1` - Scrape + upsert un provider
- `Events.sync_all/0` - Sync tous les providers en parallèle (Task.async_stream)
- `Events.subscribe/0` - Subscribe au PubSub pour les updates
- Bouton "Actualiser" déclenche `sync_all` puis reload depuis DB

**Validation**:
- ✅ `mix compile` - OK
- ✅ `mix ecto.migrate` - OK (table + 3 index créés)
- ✅ `mix test test/samuser/ --exclude external` - 36 tests, 0 failures

**Statut**: SHAPE samuser TERMINÉ

## [2026-01-18 12:50] FIX 🤖 - Nettoyage events obsolètes

**Contexte**: Bug identifié - les events supprimés du site restaient en DB
**Solution**: Diff par checksum avant upsert
**Fichier modifié**: `lib/samuser/events.ex`

**Logique ajoutée dans sync_provider/1**:
1. Calcul `new_checksums` = checksums des events scrapés
2. Query `old_checksums` = checksums actuels en DB pour ce provider
3. `to_delete` = old - new (MapSet.difference)
4. DELETE les events dont le checksum est dans `to_delete`
5. Upsert les events scrapés

**Retour**: `{:ok, %{inserted: n, deleted: m}}`

# Todos: samuser

## Fichiers créés (par Lead)

- [x] Créer `lib/samuser/providers/provider.ex` (behaviour isolé)
- [x] Créer `lib/samuser/providers/musee_zoo.ex`
- [x] Créer `lib/samuser/events/event_data.ex` (validation)
- [x] Créer `lib/samuser/events.ex` (contexte)
- [x] Créer `test/samuser/providers/musee_zoo_test.exs`
- [x] Créer `lib/dessousaine_web/live/samuser_live.ex`
- [x] Créer `lib/dessousaine_web/live/samuser_live.html.heex`

## À valider (reprise manuelle)

- [x] `mix compile` - OK
- [x] `mix test test/samuser/` - 6 tests, 0 failures
- [x] Valider la structure HTML du musée zoologique - sélecteurs génériques fonctionnent (9 expos trouvées)
- [x] Vérifier le badge rouge pour dates manquantes dans l'UI - implémenté (lignes 116-119)

## Points bloquants

- Aucun

## Statut

- [x] Spec clarifiée
- [x] Décisions figées
- [x] Fichiers créés
- [x] Compilation validée
- [x] Tests passent
- [x] Badge rouge implémenté
- [ ] **EN PAUSE** - Stockage DB manquant

## Correction requise (non fait par le Lead)

- [ ] Creer schema Ecto `Samuser.Events.Event` (comme `WeeklySchedule`)
- [ ] Creer migration pour table `samuser_events`
- [ ] Modifier `Events` context pour upsert en DB
- [ ] Ajouter `inserted_at` / `updated_at`
- [ ] Tri par `inserted_at` desc (recents en premier)

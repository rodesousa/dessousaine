# MODE: LEAD

> **Extension de** : [MODE SQUAD](./squad_raw.md) → [MODE SHAPE](./shapes_raw.md)
>
> ⚠️ **Prérequis** : Lire `shapes_raw.md` puis `squad_raw.md` avant d'utiliser cette extension.

---

## Principe

Le MODE LEAD **redéfinit** la répartition des responsabilités entre PO et Lead.

**Sans Lead (MODE SQUAD)** : Le PO fait tout (stratégie + opérationnel + dispatch)
**Avec Lead (MODE LEAD)** : Le PO fait la stratégie, le Lead fait l'opérationnel

**Analogie** :
- PO = Product Owner → définit le "quoi" et le "pourquoi"
- Lead = Tech Lead → gère le "comment" et le "où on en est"

---

## Problème résolu

Sans séparation claire, le PO doit :
1. Lire le SHAPE (~20-30k tokens)
2. Lire le code pour comprendre le contexte (~20-30k tokens)
3. Dispatcher les Dev
4. Tracker la progression

**Résultat** : PO à 50k+ tokens, context bloat, risque d'erreur.

Avec Lead :
- Le PO reste léger (SHAPE stratégique uniquement)
- Le Lead gère tout l'opérationnel (code + dispatch + tracking)
- Séparation des contextes = meilleure efficacité

---

## Répartition des fichiers SHAPE

| Fichier | Contenu | Qui écrit |
|---------|---------|-----------|
| `spec.md` | Objectifs, contraintes, pourquoi | 📋 PO |
| `plan.md` | Stratégie, découpage phases | 📋 PO |
| `decisions.md` | Arbitrages figés | 📋 PO |
| `README.md` | Statut du SHAPE | 📋 PO |
| `todos.md` | Tâches, progression | 🧑‍💻 Lead |
| `tracelog.md` | Journal des actions | 🧑‍💻 Lead |

### Logique de la séparation

```
📋 PO = Stratégique (stable)
├── spec.md      → QUOI on veut
├── plan.md      → COMMENT on découpe
├── decisions.md → CE QUI est figé
└── README.md    → OÙ on en est (statut)

🧑‍💻 Lead = Opérationnel (évolue)
├── todos.md     → progression détaillée
├── tracelog.md  → historique des actions
└── dispatch     → lance les Dev
```

---

## Rôles redéfinis

| Agent | Emoji | Responsabilité |
|-------|-------|----------------|
| **PO** | 📋 | Définit la stratégie, maintient spec/plan/decisions, valide le résultat final |
| **Lead** | 🧑‍💻 | Orchestre l'exécution, analyse le code, dispatch Dev, track la progression |
| **Dev** | 🛠️ | Implémente (backend + front + qualité) |

---

## Principe clé : Séparation des contextes

| Agent | Lit SHAPE stratégique | Lit SHAPE opérationnel | Lit code |
|-------|----------------------|------------------------|----------|
| 📋 PO | ✅ spec, plan, decisions | ❌ Non | ❌ Non |
| 🧑‍💻 Lead | ✅ spec, plan, decisions | ✅ todos, tracelog | ✅ Oui |
| 🛠️ Dev | ❌ Non | ❌ Non | ✅ Oui (ciblé) |

**Le PO ne lit jamais le code.**
**Le Lead ne modifie jamais les fichiers stratégiques.**

---

## Architecture

```
     ┌──────────────────┐
     │      📋 PO       │
     │  (stratégique)   │
     └────────┬─────────┘
              │ 1. Prépare spec/plan/decisions
              │ 2. Lance le Lead
              │
              ▼
     ┌──────────────────┐
     │    🧑‍💻 Lead      │
     │  (opérationnel)  │
     └────────┬─────────┘
              │ • Lit spec/plan/decisions (contexte)
              │ • Analyse le code
              │ • Crée/gère todos.md
              │ • Dispatch Dev
              │ • Log dans tracelog.md
              │
              ▼
     ┌──────────────────┐
     │     🛠️ Dev       │
     │ (implémentation) │
     └────────┬─────────┘
              │
              ▼
     ┌──────────────────┐
     │    🧑‍💻 Lead      │
     │   (sync & log)   │
     └────────┬─────────┘
              │ • Met à jour todos.md
              │ • Log dans tracelog.md
              │ • Si terminé → informe PO
              │
              ▼
     ┌──────────────────┐
     │      📋 PO       │
     │   (clôture)      │
     └──────────────────┘
              │ • Vérifie le résultat
              │ • Met à jour README.md → DONE
```

---

## Workflow détaillé

### 1. PO prépare le SHAPE

Le PO crée/complète les fichiers stratégiques :

```markdown
spec.md     → Contexte, objectif, contraintes, hors scope
plan.md     → Découpage en phases, approche technique
decisions.md → Choix technologiques figés
```

Le PO met le statut à `READY 🟢` dans README.md.

### 2. PO lance le Lead

```
Task tool:
  subagent_type: "general-purpose"
  run_in_background: true
  prompt: |
    Tu es un Lead technique 🧑‍💻 pour le SHAPE shapes/<nom>.

    ## Ta mission

    Orchestrer l'implémentation du SHAPE jusqu'à complétion.

    ## Fichiers stratégiques (contexte - ne pas modifier)

    Lis ces fichiers pour comprendre le contexte :
    - shapes/<nom>/spec.md
    - shapes/<nom>/plan.md
    - shapes/<nom>/decisions.md

    ## Fichiers opérationnels (tu gères)

    Tu crées et maintiens :
    - shapes/<nom>/todos.md → liste des tâches et progression
    - shapes/<nom>/tracelog.md → journal de tes actions

    ## Ton workflow

    1. Lis les fichiers stratégiques
    2. Analyse le code existant pour comprendre les patterns
    3. Crée todos.md avec les tâches découpées
    4. Pour chaque tâche ou groupe de tâches :
       a. Log DISPATCH dans tracelog.md
       b. Lance un Dev avec les specs précises
       c. Attends le résultat
       d. Log IMPL dans tracelog.md
       e. Marque [x] dans todos.md
    5. Quand tout est terminé, signale "LEAD TERMINÉ"

    ## Règles

    - Tu peux lire tout le code
    - Tu ne modifies PAS le code (le Dev le fait)
    - Tu ne modifies PAS spec.md, plan.md, decisions.md
    - Tu gères todos.md et tracelog.md
```

### 3. Lead analyse et prépare

Le Lead :
1. Lit spec.md, plan.md, decisions.md
2. Explore le code pour comprendre les patterns existants
3. Crée `todos.md` avec les tâches découpées
4. Log dans `tracelog.md`

```markdown
## todos.md (créé par Lead)

# Tâches - SHAPE feature_x

## Phase 1: Cache layer

- [ ] Ajouter Cachex aux dépendances
- [ ] Configurer Cachex dans supervision tree
- [ ] Créer module QuotesCache

## Phase 2: LiveView skeleton

- [ ] Créer Lucille6Live
- [ ] Template de base avec AG-Grid
- [ ] Mount avec chargement initial

...
```

### 4. Lead dispatch les Dev

Pour chaque tâche ou groupe de tâches, le Lead :

```
Task tool:
  subagent_type: "general-purpose"
  run_in_background: true
  prompt: |
    Tu es un Dev 🛠️.

    ## Tâches à implémenter

    1. Ajouter Cachex aux dépendances (mix.exs)
    2. Configurer Cachex dans supervision tree (application.ex)
    3. Créer module QuotesCache avec API:
       - store_temp/2
       - get_temp/1
       - promote_to_analysis/2

    ## Patterns à suivre

    - Voir Roda.SomeExistingCache pour le pattern module
    - TTL: 1 minute pour temp, 10 minutes pour analysis

    ## Contraintes (depuis decisions.md)

    - D1: Utiliser Cachex, pas ETS
    - D4: Clés = {:temp, socket_id} et {:analysis, analysis_id}

    ## Règles

    - Qualité: gettext pour les strings UI, tests si pertinent
    - Lance `mix compile` avant de terminer
```

### 5. Lead synchronise

Quand le Dev termine, le Lead :
1. Vérifie l'output du Dev
2. Met à jour `todos.md` (marque [x])
3. Ajoute une entrée IMPL dans `tracelog.md`
4. Continue avec les tâches suivantes ou signale "TERMINÉ"

### 6. PO clôture

Quand le Lead signale "TERMINÉ" :
1. Le PO vérifie que les objectifs de spec.md sont atteints
2. Le PO met à jour README.md → `DONE ✅`

---

## Tracelog avec Lead

Le Lead écrit toutes les entrées opérationnelles :

```markdown
## [2025-01-14 10:00] ANALYZE 🧑‍💻 - Analyse initiale

**Contexte**: Début de session Lead
**Fichiers lus**: spec.md, plan.md, decisions.md
**Code analysé**: lucille5_live.ex, aggrid.ts
**Détail**: Patterns identifiés, todos.md créé

---

## [2025-01-14 10:15] DISPATCH 🧑‍💻 - Lancement Phase 1

**Tâches**: Cachex deps, config, QuotesCache module
**Détail**: Dev lancé (task_id: a817671)

---

## [2025-01-14 10:30] IMPL 🛠️ - Phase 1 complète

**Tâches**:
- ✅ Cachex ajouté aux dépendances
- ✅ Cachex configuré
- ✅ QuotesCache créé
**Fichiers modifiés**: mix.exs, application.ex, quotes_cache.ex
**Source**: task a817671

---

## [2025-01-14 10:35] DISPATCH 🧑‍💻 - Lancement Phase 2

**Tâches**: LiveView skeleton, template, mount
**Détail**: Dev lancé (task_id: b92847)

---

## [2025-01-14 11:00] SYNC 🧑‍💻 - Toutes phases complètes

**Résumé**:
- Phase 1: ✅
- Phase 2: ✅
- Phase 3: ✅
**Statut**: LEAD TERMINÉ - prêt pour clôture PO
```

---

## Verbes tracelog (mise à jour)

| Verbe | Qui l'utilise | Usage |
|-------|---------------|-------|
| CRÉER | 📋 PO | Création initiale d'un fichier stratégique |
| MODIFIER | 📋 PO | Mise à jour spec/plan/decisions |
| CLARIFIER | 📋 PO | Précision suite à question |
| DÉCIDER | 📋 PO | Ajout décision figée |
| PROMOUVOIR | 📋 PO | Changement de statut SHAPE |
| ANALYZE | 🧑‍💻 Lead | Analyse code/contexte |
| DISPATCH | 🧑‍💻 Lead | Lancement d'un Dev |
| IMPL | 🛠️ Dev (via Lead) | Implémentation terminée |
| SYNC | 🧑‍💻 Lead | Point de synchronisation |

---

## Règles de séparation (complètes)

| Agent | Lit | Écrit |
|-------|-----|-------|
| 📋 PO | spec, plan, decisions, README | spec, plan, decisions, README |
| 🧑‍💻 Lead | spec, plan, decisions (lecture) + todos, tracelog + code | todos, tracelog |
| 🛠️ Dev | code (ciblé, via prompt Lead) | code |

---

## Commandes

```
MODE LEAD sur shapes/<nom>      → PO active le Lead sur un SHAPE READY
LEAD STATUS                     → Affiche progression du Lead actif
```

---

## Quand utiliser MODE LEAD vs MODE SQUAD

| Situation | Mode | Raison |
|-----------|------|--------|
| Feature simple, < 5 tâches | SQUAD | Overhead Lead inutile |
| Feature complexe, multi-phases | LEAD | Lead gère la complexité |
| Besoin d'analyser beaucoup de code | LEAD | Lead a le contexte code |
| Bug fix localisé | SQUAD | Direct au Dev |
| Refactoring multi-fichiers | LEAD | Lead coordonne |

**Règle simple** : Si tu sens que le PO devrait lire du code → utilise LEAD.

---

## Récap : chaîne d'extensions

```
shapes_raw.md          # Base: structure SHAPE
       │
       │ étend
       ▼
squad_raw.md           # PO fait tout (stratégie + opérationnel)
       │
       │ étend (redéfinit répartition)
       ▼
lead_raw.md            # PO = stratégie, Lead = opérationnel
```

Le MODE LEAD n'ajoute pas juste un rôle — il **redistribue** les responsabilités pour une meilleure séparation des contextes.

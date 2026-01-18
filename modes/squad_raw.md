# MODE: SQUAD

> **Extension de** : [MODE SHAPE](./shapes_raw.md)
>
> ⚠️ **Prérequis** : Lire et comprendre `shapes_raw.md` avant d'utiliser cette extension.

---

## Principe

Le MODE SQUAD est une **extension** du MODE SHAPE qui ajoute un moteur d'exécution par agents parallèles.

**Analogie jeu de société** :
- `shapes_raw.md` = règles de base du jeu
- `squad_raw.md` = extension "Mode Campagne" qui ajoute de nouvelles mécaniques

Tout ce qui est défini dans `shapes_raw.md` reste valide. Cette extension ajoute uniquement :
- 2-3 rôles (agents) selon configuration
- 4 nouveaux verbes pour le tracelog
- 2 nouveaux tags de source
- Un workflow basé sur le **Task tool** de Claude Code

---

## Configuration

| Option | Valeur | Description |
|--------|--------|-------------|
| `lead` | `false` (défaut) | PO fait tout (stratégie + opérationnel) |
| `lead` | `true` | PO = stratégie, Lead = opérationnel |

### Quand activer le Lead ?

**Règle simple** : Si le PO devrait lire du code → `lead: true`

| Situation | lead | Raison |
|-----------|------|--------|
| Feature simple, < 5 tâches | `false` | Overhead Lead inutile |
| Bug fix localisé | `false` | Direct au Dev |
| Feature complexe, multi-phases | `true` | Lead gère la complexité |
| Refactoring multi-fichiers | `true` | Lead coordonne |
| Besoin d'analyser beaucoup de code | `true` | Lead a le contexte code |

### Problème résolu par le Lead

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

## Rôles

| Agent | Emoji | Présent si | Responsabilité |
|-------|-------|------------|----------------|
| **PO** | 📋 | toujours | Dispatche, synchronise, met à jour le SHAPE |
| **Lead** | 🧑‍💻 | `lead: true` | Orchestre l'exécution, analyse le code, **délègue TOUJOURS au Dev**, track la progression |
| **Dev** | 🛠️ | toujours | Implémente (backend + front + qualité intégrée) |

> ⚠️ **Règle fondamentale** : Le Lead **ne code jamais**. Toute modification de code passe par un Dev.

---

## Répartition des responsabilités

### Sans Lead (`lead: false` - défaut)

```
📋 PO = Tout
├── spec.md, plan.md, decisions.md  → QUOI et COMMENT
├── todos.md, tracelog.md           → progression
├── README.md                       → statut
├── Lecture code                    → pour comprendre le contexte
└── Dispatch Dev                    → lance les implémentations
```

| Agent | Lit | Écrit |
|-------|-----|-------|
| 📋 PO | SHAPE complet + code | README, todos, decisions, tracelog |
| 🛠️ Dev | code (ciblé, via prompt PO) | code |

### Avec Lead (`lead: true`)

```
📋 PO = Stratégique (stable)
├── spec.md      → QUOI on veut
├── plan.md      → COMMENT on découpe
├── decisions.md → CE QUI est figé
└── README.md    → OÙ on en est (statut)

🧑‍💻 Lead = Opérationnel (évolue)
├── todos.md     → progression détaillée
├── tracelog.md  → historique des actions
├── Lecture code → analyse et patterns
└── dispatch     → lance les Dev
```

| Agent | Lit | Écrit |
|-------|-----|-------|
| 📋 PO | spec, plan, decisions, README | spec, plan, decisions, README |
| 🧑‍💻 Lead | spec, plan, decisions (lecture) + todos, tracelog + code | todos, tracelog |
| 🛠️ Dev | code (ciblé, via prompt Lead) | code |

**Le PO ne lit jamais le code** (quand `lead: true`).
**Le Lead ne modifie jamais les fichiers stratégiques.**
**Le Lead ne modifie jamais le code** → il délègue TOUJOURS au Dev.

---

## Verbes tracelog

À ajouter aux verbes de `shapes_raw.md` :

| Verbe | Qui l'utilise | Usage |
|-------|---------------|-------|
| **DISPATCH** | 📋 PO ou 🧑‍💻 Lead | Assigne une tâche à un Dev |
| **IMPL** | 🛠️ Dev (via PO/Lead) | Termine une implémentation |
| **SYNC** | 📋 PO ou 🧑‍💻 Lead | Fait le point sur l'avancement |
| **ANALYZE** | 🧑‍💻 Lead | Analyse code/contexte (si `lead: true`) |

### Tags source

| Tag | Qui écrit |
|-----|-----------|
| 📋 | PO (agent orchestrateur) |
| 🧑‍💻 | Lead (agent opérationnel) |
| 🛠️ | Dev (agent implémenteur) |

---

## Conditions d'activation

Le MODE SQUAD ne peut être activé que si :

1. Un SHAPE existe avec le statut `READY 🟢`
2. Le fichier `todos.md` contient des tâches à exécuter
3. Les fichiers `spec.md` et `decisions.md` sont stabilisés

---

## Règle de délégation obligatoire

> 🚨 **Le Lead ne code JAMAIS. Toute implémentation passe par un Dev.**

### Pourquoi cette règle ?

Le Lead accumule beaucoup de contexte :
- Fichiers stratégiques : spec + plan + decisions (~10-15k tokens)
- Code analysé : patterns, architecture (~20-30k tokens)
- Fichiers opérationnels : todos + tracelog (variable)

S'il implémente lui-même, il ajoute encore plus de contexte (éditions, tests, debug).
**Résultat** : context bloat, perte de qualité, risque d'erreur.

### Ce que le Lead peut faire

| Action | Autorisé | Exemple |
|--------|----------|---------|
| Lire du code | ✅ | Analyser les patterns existants |
| Lire le SHAPE | ✅ | Comprendre spec, plan, decisions |
| Écrire todos.md | ✅ | Tracker la progression |
| Écrire tracelog.md | ✅ | Logger les actions |
| **Modifier du code** | ❌ | Doit spawner un Dev |
| **Créer des fichiers code** | ❌ | Doit spawner un Dev |
| **Lancer des tests** | ❌ | Le Dev inclut les tests |

### Ce que le Lead DOIT faire

Pour **toute** tâche impliquant du code :

1. Préparer un prompt précis pour le Dev
2. Spawner le Dev via `Task tool` (background)
3. Surveiller l'avancement
4. Logger le résultat dans tracelog.md
5. Marquer la tâche dans todos.md

### Avantages

- **Contexte Lead léger** : reste focalisé sur l'orchestration
- **Parallélisation possible** : plusieurs Dev en même temps
- **Traçabilité claire** : chaque implémentation a son task_id
- **Qualité garantie** : le Dev a un contexte frais et focalisé

---

## Architecture des agents

### Sans Lead

```
     ┌──────────────┐
     │    📋 PO     │  ← agent principal (foreground)
     └──────┬───────┘
            │ lance via Task tool
            │ (run_in_background: true)
            ▼
     ┌──────────────┐
     │   🛠️ Dev     │  ← agent background
     └──────────────┘
            │ output automatique dans
            ▼
     ┌────────────────────────────────────────┐
     │ /tmp/claude/.../tasks/<task_id>.output │
     └────────────────────────────────────────┘
```

### Avec Lead

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
```

Le PO peut lancer **plusieurs Dev en parallèle** (ou le Lead peut le faire si `lead: true`) si les tâches sont indépendantes.

---

## Communication via Task tool

Le MODE SQUAD utilise le mécanisme natif de Claude Code pour la communication entre agents.

### Comment ça marche

Quand le PO (ou Lead) lance un Dev avec `run_in_background: true`, Claude Code :
1. Crée un fichier output : `/tmp/claude/.../tasks/<task_id>.output`
2. Y écrit tout ce que le Dev fait (actions, réflexions, résultats)
3. Retourne le `task_id` et le chemin du fichier

### Comment surveiller le Dev

**Option 1** : Tool `TaskOutput` (recommandé)
```
TaskOutput:
  task_id: "<task_id>"
  block: false        # non-bloquant, retourne l'état actuel
  timeout: 5000
```

**Option 2** : Lecture directe du fichier
```bash
tail -50 /tmp/claude/.../tasks/<task_id>.output
```

---

## Workflow

### 1. Activation

```
Humain: "MODE SQUAD sur shapes/feature_x"
```

**⚠️ IMPORTANT : Toujours demander à l'utilisateur**

Au lancement, le PO **DOIT** poser la question :

```
🧑‍💻 Souhaites-tu activer le Lead pour cette session ?

• Avec Lead → PO reste stratégique, Lead gère code + dispatch
• Sans Lead → PO fait tout (stratégie + opérationnel)

Rappel - Utiliser le Lead si :
- Feature complexe, multi-phases
- Besoin d'analyser beaucoup de code
- Refactoring multi-fichiers
```

L'utilisateur peut aussi forcer directement :
```
Humain: "MODE SQUAD --lead sur shapes/feature_x"   # force lead: true
Humain: "MODE SQUAD --no-lead sur shapes/feature_x" # force lead: false
```

### 2. Initialisation

Le PO :
1. Lit tous les fichiers du SHAPE
2. Vérifie que le statut est `READY 🟢`
3. Met à jour `README.md` → `IN_PROGRESS 🔵`
4. Si `lead: true` → lance le Lead
5. Sinon → analyse `todos.md` et lance directement les Dev

### 3a. Workflow sans Lead

Le PO analyse les tâches et lance les Dev :

```
Task tool:
  subagent_type: "general-purpose"
  run_in_background: true
  prompt: |
    Tu es un agent Dev 🛠️ pour le SHAPE shapes/feature_x.

    ## Ta mission
    Implémenter les tâches de ta file dans l'ordre.

    ## Ta file de tâches
    1. [Tâche 1]
    2. [Tâche 2]
    ...

    ## Règles
    - Implémente chaque tâche complètement avant de passer à la suivante
    - Qualité incluse: gettext, tests, documentation
    - Si tu rencontres un bloquant, documente-le clairement et continue
      sur ce que tu peux faire

    ## Contexte
    Lis spec.md, plan.md, decisions.md avant de commencer.
```

### 3b. Workflow avec Lead

Le PO lance le Lead :

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

    ## Règles STRICTES

    🚨 **DÉLÉGATION OBLIGATOIRE** :
    - Tu ne TOUCHES JAMAIS au code (ni création, ni modification)
    - Tu ne lances JAMAIS de tests toi-même
    - Pour TOUTE action sur le code → spawner un Dev

    ✅ Ce que tu peux faire :
    - Lire le code (analyse, patterns)
    - Écrire todos.md et tracelog.md
    - Spawner des Dev via Task tool

    ❌ Ce que tu ne fais JAMAIS :
    - Modifier du code
    - Créer des fichiers .ex, .exs, .ts, .js, etc.
    - Lancer mix test, npm test, etc.
    - Modifier spec.md, plan.md, decisions.md
```

### 4. Boucle de surveillance

Le PO (ou le Lead s'il est actif) surveille la progression :

```
while Dev is running:
    # Vérifier l'état du Dev
    TaskOutput(task_id, block=false)

    # Ou lire directement
    tail -50 <output_file>

    si Dev terminé:
        - lire le résumé des actions
        - marquer tâches dans todos.md [x]
        - ajouter entrées IMPL 🛠️ dans tracelog.md
        - si plus de tâches: clôturer
        - sinon: lancer un nouveau Dev pour la suite

    si Dev bloqué (visible dans l'output):
        - analyser le bloquant
        - résoudre ou escalader à l'humain
        - relancer un Dev avec les instructions mises à jour

    attendre ~30 secondes entre les checks
```

### 5. Multi-Dev (optionnel)

Quand le PO/Lead identifie des tâches parallélisables :

```
     ┌──────────────┐
     │  📋 PO ou    │
     │  🧑‍💻 Lead    │
     └──────┬───────┘
            │
      ┌─────┴─────┐
      ▼           ▼
┌─────────┐ ┌─────────┐
│🛠️ Dev 1 │ │🛠️ Dev 2 │  ← 2 Task tool calls en parallèle
└────┬────┘ └────┬────┘
     │           │
     ▼           ▼
task_1.output   task_2.output   ← outputs séparés
```

**Critères de parallélisation :**
- Pas de fichiers partagés entre les tâches
- Domaines différents (ex: cache vs UI)
- Explicitement marqué dans `plan.md`

### 6. Clôture

Quand toutes les tâches sont terminées :
1. PO/Lead ajoute une entrée `SYNC` finale dans `tracelog.md`
2. Si `lead: true` : Lead signale "LEAD TERMINÉ"
3. PO met à jour `README.md` → `DONE ✅`
4. PO ajoute une entrée `PROMOUVOIR` dans `tracelog.md`

---

## Gestion des bloquants

Si le Dev rencontre un choix non couvert par `decisions.md` :

1. Le Dev documente le bloquant dans son output et continue sur ce qu'il peut faire
2. Le PO/Lead détecte le bloquant en lisant l'output
3. Le PO décide et ajoute dans `decisions.md` (verbe `DÉCIDER`)
4. Le PO/Lead lance un nouveau Dev avec la décision incluse dans le prompt

---

## Commandes

```
MODE SQUAD sur shapes/<nom>          → Active le mode (demande lead: oui/non)
MODE SQUAD --lead sur shapes/<nom>   → Active le mode avec Lead (sans question)
MODE SQUAD --no-lead sur shapes/<nom>→ Active le mode sans Lead (sans question)
SQUAD STATUS                         → Lit les outputs des Dev/Lead actifs
SQUAD SYNC                           → Force une synchronisation
```

---

## Exemples

### Session sans Lead

#### 1. PO dispatch

```markdown
## [2025-01-14 10:00] DISPATCH 📋 - Lancement SQUAD

**Contexte**: SHAPE feature_x passé en IN_PROGRESS
**Détail**:
- Dev lancé en background (task_id: a817671)
- File de tâches: Cachex deps, Cachex config, QuotesCache module, Tests
```

#### 2. Dev terminé, PO synchronise

```markdown
## [2025-01-14 10:30] IMPL 🛠️ - Phase 1 complète

**Tâches**:
- ✅ Cachex ajouté aux dépendances
- ✅ Cachex configuré dans supervision tree
- ✅ QuotesCache module créé
- ✅ 13 tests passants
**Fichiers**: mix.exs, lib/roda/application.ex, lib/roda/quotes_cache.ex, test/...
**Source**: task a817671

---

## [2025-01-14 10:35] SYNC 📋 - Passage à Phase 2

**Détail**: todos.md mis à jour, nouveau Dev lancé pour Phase 2
```

### Session avec Lead

#### 1. PO lance le Lead

```markdown
## [2025-01-14 10:00] DISPATCH 📋 - Lancement Lead

**Contexte**: SHAPE feature_x passé en IN_PROGRESS
**Détail**: Lead lancé (task_id: lead-8273)
```

#### 2. Lead analyse et dispatch

```markdown
## [2025-01-14 10:05] ANALYZE 🧑‍💻 - Analyse initiale

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

## [2025-01-14 11:00] SYNC 🧑‍💻 - Toutes phases complètes

**Résumé**:
- Phase 1: ✅
- Phase 2: ✅
- Phase 3: ✅
**Statut**: LEAD TERMINÉ - prêt pour clôture PO
```

---

## Rappel : ce qui vient de shapes_raw.md

Cette extension **ne redéfinit pas** :
- La structure des fichiers (README, spec, plan, todos, decisions, tracelog)
- Les états du SHAPE (DRAFT, CLARIFYING, READY, IN_PROGRESS, DONE, PAUSED)
- Les verbes de base du tracelog (CRÉER, MODIFIER, CLARIFIER, DÉCIDER, etc.)
- Les tags de base (🤖, 👤)
- Les règles de mise à jour du MODE SHAPE

Pour ces éléments, référez-vous à [shapes_raw.md](./shapes_raw.md).

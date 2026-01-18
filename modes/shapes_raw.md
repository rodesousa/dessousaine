# MODE: SHAPE

Détail du mode SHAPE, qui définit une **mémoire de travail persistante et explicite**
pour un LLM / Agent.

---

## Principe

Dans la racine du projet, il existe un dossier `shapes/`
(créé s'il n'existe pas).

Chaque SHAPE correspond à un sous-dossier identifié par un nom explicite
(`plan_name/`, `feature_x/`, etc.).

Structure attendue :

```
shapes/
├── plan_name/
│   ├── README.md
│   ├── spec.md
│   ├── plan.md
│   ├── todos.md
│   ├── decisions.md
│   └── tracelog.md
```

Le but est :
**vision → stratégie → exécution**

Le dossier `shapes/` est en réalité :
- un prompt distribué
- qui évolue dans le temps
- et qui survit aux resets de contexte

---

## Comportement du MODE SHAPE

Quand le MODE SHAPE est actif, l'agent doit :

- Cesser toute exploration libre
- Ne pas proposer de solution, de plan ou d'implémentation
- Ne pas ouvrir de nouvelles pistes
- Travailler uniquement à partir du contexte existant
- Structurer et figer l'état courant du raisonnement

Le MODE SHAPE **ne décide pas**,
il **stabilise**.

---

## Fichiers et responsabilités

### spec.md → le "pourquoi"

Contient exclusivement :
- le contexte
- l'objectif
- les contraintes
- les hypothèses explicites
- les inconnues
- le hors scope

Aucune stratégie, aucun découpage opérationnel.

---

### plan.md → le "comment"

Peut être vide ou partiel.
Le MODE SHAPE **ne complète pas le plan**,
il vérifie uniquement sa cohérence avec `spec.md`.

---

### todos.md → le "où on en est"

Contient :
- ce qui est fait
- ce qui reste à faire
- les points bloquants
- les éléments prêts pour une planification

---

### decisions.md → les décisions figées

Contient :
- les décisions prises
- les options explicitement rejetées
- les arbitrages non réversibles

Ce fichier fait autorité pour éviter toute re-proposition.

---

### tracelog.md → le "journal des actions" (méta)

Fichier méta qui trace chronologiquement toutes les actions du LLM sur le SHAPE.
Fonctionne comme un git log textuel.

**Format d'une entrée :**

```
## [YYYY-MM-DD HH:MM] VERBE - Résumé court

**Contexte**: Pourquoi cette action
**Fichiers modifiés**: liste des fichiers
**Détail**: Description des changements
```

**Verbes standardisés :**

| Verbe | Usage |
|-------|-------|
| CRÉER | Création initiale d'un fichier |
| MODIFIER | Mise à jour d'un contenu existant |
| CLARIFIER | Ajout de précision suite à une question user |
| DÉCIDER | Ajout d'une nouvelle décision figée |
| REJETER | Ajout d'une option explicitement rejetée |
| VALIDER | Passage d'hypothèse à confirmé |
| PROMOUVOIR | Changement de statut (ex: spec validée → prêt pour implémentation) |
| CORRIGER | Fix d'une erreur ou incohérence |
| FEEDBACK | Retour du développeur (humain, pas AI) |

**Source des entrées :**

| Tag | Qui écrit |
|-----|-----------|
| 🤖 | AI (agent LLM) |
| 👤 | Humain (développeur) |

Le tag doit apparaître dans le résumé court, ex:
- `## [2025-01-13 10:30] FEEDBACK 👤 - Retour sur la structure spec/todos`
- `## [2025-01-13 10:00] CRÉER 🤖 - Initialisation du SHAPE`

**Objectif :**
- Traçabilité complète des évolutions du SHAPE
- Permet l'analyse post-mortem pour améliorer le MODE SHAPE
- Survit aux resets de contexte (l'agent peut relire l'historique)

---

## États d'un SHAPE

Un SHAPE passe par des états explicites. Le statut courant doit être visible dans `README.md`.

| État | Emoji | Description |
|------|-------|-------------|
| `DRAFT` | 🔴 | Brouillon initial, en cours de construction |
| `CLARIFYING` | 🟠 | En attente de clarifications (inconnues à résoudre) |
| `READY` | 🟢 | Spec validée, prêt pour implémentation |
| `IN_PROGRESS` | 🔵 | Implémentation en cours |
| `DONE` | ✅ | Terminé |
| `PAUSED` | ⏸️ | En pause (contexte changé, priorité baissée) |

**Affichage dans README.md :**

```markdown
# SHAPE: nom_du_shape

**Statut**: 🟢 READY

[...]
```

Le verbe `PROMOUVOIR` dans le tracelog sert à tracer les changements d'état.

---

## Règles de mise à jour

En MODE SHAPE, l'agent peut :
- créer les fichiers manquants
- compléter ou corriger les fichiers existants
- rendre explicites les hypothèses implicites

L'agent ne doit **jamais** :
- modifier une décision sans le signaler explicitement
- transformer une hypothèse en décision
- anticiper l'exécution

---

## En cas de reprise ou de changement d'intention

Lorsqu'un SHAPE existant est réutilisé :

- Lire **tous** les fichiers du SHAPE concerné
- Se baser prioritairement sur `decisions.md`
  et sur la partie non terminée de `todos.md`
- Si une divergence avec l'intention actuelle est détectée :
  - rappeler le contexte existant
  - expliciter le conflit
  - poser une suite de questions ciblées
  - ne rien modifier tant que l'intention n'est pas clarifiée

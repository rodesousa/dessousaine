# MODE: ANALYSE

> **Utilisable après** : Une session SHAPE ou SQUAD (avec ou sans Lead)
>
> Ce mode capture le **retour d'expérience** d'un agent sur sa session.

---

## Principe

Le MODE ANALYSE est un mode de **rétrospective** activé en fin de session.

L'agent qui vient de travailler décrit :
- Ce qui s'est bien passé
- Ce qui a été difficile
- Les frictions rencontrées
- Ses suggestions d'amélioration

**But** : Capturer le feedback à chaud, quand le contexte est encore frais.

---

## Quand l'utiliser

```
Humain: "MODE ANALYSE"
```

À activer :
- Après une session SQUAD terminée
- Quand un agent a rencontré des difficultés
- Pour améliorer les modes de travail

---

## Output attendu

L'agent produit un fichier `analyse_XX.md` dans le dossier du SHAPE, où `XX` est le prochain numéro disponible.

### Règle de nommage

1. Lister les fichiers `analyse_*.md` existants dans le dossier SHAPE
2. Trouver le plus grand numéro existant
3. Incrémenter de 1

```
shapes/
├── feature_x/
│   ├── ... (fichiers SHAPE)
│   ├── analyse_0.md    ← première analyse
│   ├── analyse_1.md    ← deuxième analyse
│   └── analyse_2.md    ← troisième analyse (audit post-DONE par ex)
```

### Exemple de détermination du numéro

```
Si le dossier contient:
  - analyse_0.md
  - analyse_1.md

Alors le prochain fichier sera: analyse_2.md
```

```
Si le dossier ne contient aucun fichier analyse_*.md:

Alors le premier fichier sera: analyse_0.md
```

---

## Format du fichier analyse

```markdown
# Analyse de session

**Fichier**: analyse_XX.md
**Date**: YYYY-MM-DD
**SHAPE**: nom_du_shape
**Mode utilisé**: SQUAD | SQUAD --lead
**Agent**: 📋 PO | 🧑‍💻 Lead | 🛠️ Dev
**Durée estimée**: Xh ou X minutes

---

## Résumé de la session

[2-3 phrases sur ce qui a été fait]

---

## ✅ Ce qui a bien fonctionné

- [Point positif 1]
- [Point positif 2]
- ...

---

## ⚠️ Difficultés rencontrées

### [Difficulté 1]

**Contexte**: [Qu'est-ce qui s'est passé]
**Impact**: [Comment ça a affecté le travail]
**Contournement**: [Comment j'ai géré, si applicable]

### [Difficulté 2]

...

---

## 🔧 Frictions avec les modes

### [Friction 1]

**Mode concerné**: shapes_raw | squad_raw
**Description**: [Ce qui ne marche pas bien]
**Suggestion**: [Comment améliorer]

### [Friction 2]

...

---

## 💡 Suggestions d'amélioration

### [Suggestion 1]

**Problème**: [Ce que ça résout]
**Proposition**: [Description de l'amélioration]
**Priorité**: Haute | Moyenne | Basse

### [Suggestion 2]

...

---

## 📊 Métriques (si disponibles)

- **Tokens consommés**: ~X k
- **Nombre de tâches**: X complétées / Y totales
- **Fichiers modifiés**: X
- **Bloquants rencontrés**: X

---

## 🎯 Pour la prochaine session

[Recommandations pour quelqu'un qui reprendrait ce SHAPE]
```

---

## Questions guides pour l'agent

Si l'agent a du mal à structurer son feedback, il peut répondre à ces questions :

### Sur le workflow

1. Le découpage des tâches dans `todos.md` était-il clair ?
2. Les specs dans `plan.md` étaient-elles suffisantes ?
3. As-tu dû relire plusieurs fois les mêmes fichiers ?
4. Le prompt initial contenait-il assez de contexte ?

### Sur la communication

1. (Si SQUAD --lead) La séparation PO/Lead/Dev était-elle claire ?
2. As-tu manqué d'information à un moment ?
3. Aurais-tu eu besoin de poser une question à l'humain ?

### Sur les outils

1. Le Task tool a-t-il bien fonctionné ?
2. As-tu rencontré des limites de contexte ?
3. Y a-t-il eu des erreurs techniques ?

### Sur le résultat

1. Le code produit respecte-t-il les standards (gettext, tests) ?
2. Y a-t-il de la dette technique introduite ?
3. Que ferais-tu différemment ?

---

## Exemple de fichier analyse

```markdown
# Analyse de session

**Fichier**: analyse_0.md
**Date**: 2025-01-14
**SHAPE**: lucille6_quotes_cache
**Mode utilisé**: SQUAD --lead (pour Phase 3)
**Agent**: 📋 PO
**Durée estimée**: ~45 minutes

---

## Résumé de la session

Implémentation des Phases 1-3 du cache Lucille6. Phase 1-2 (cache + LiveView skeleton)
fluides. Phase 3 (flow données) a nécessité une analyse Lead pour comprendre les
patterns existants.

---

## ✅ Ce qui a bien fonctionné

- Le découpage en phases dans `todos.md` était clair
- Les décisions dans `decisions.md` ont évité des allers-retours
- Le Lead a bien identifié les patterns à suivre dans aggrid.ts
- Le Task tool en background a bien fonctionné

---

## ⚠️ Difficultés rencontrées

### Contexte initial trop lourd

**Contexte**: Au démarrage, j'ai lu tous les fichiers SHAPE + essayé de lire le code
**Impact**: ~50k tokens avant de commencer à travailler
**Contournement**: Utilisé le Lead pour l'analyse code

### Pattern AG-Grid pas documenté

**Contexte**: Le hook aggrid.ts existait mais sans doc sur les events disponibles
**Impact**: Le Lead a dû explorer l'API AG-Grid
**Contournement**: Lead a trouvé le pattern dans handleRowSelected()

---

## 🔧 Frictions avec les modes

### Pas clair quand utiliser --lead vs direct Dev

**Mode concerné**: squad_raw
**Description**: Hésitation sur Phase 3 - fallait-il un Lead (--lead) ou direct Dev ?
**Suggestion**: Arbre de décision ajouté dans squad_raw.md (section "Quand activer le Lead ?")

### tracelog verbeux

**Mode concerné**: shapes_raw
**Description**: Beaucoup d'entrées pour chaque petite action
**Suggestion**: Regrouper les IMPL par phase plutôt qu'une entrée par tâche

---

## 💡 Suggestions d'amélioration

### Ajouter un "context budget" au PO

**Problème**: Le PO peut accidentellement consommer trop de tokens
**Proposition**: Définir une limite (~25k) et forcer l'utilisation du Lead au-delà
**Priorité**: Moyenne

### Template de prompt Dev plus structuré

**Problème**: Chaque prompt Dev est réécrit from scratch
**Proposition**: Ajouter un template dans squad_raw.md
**Priorité**: Basse

---

## 📊 Métriques

- **Tokens consommés**: ~120k (PO: 40k, Lead: 35k, Dev: 45k)
- **Nombre de tâches**: 8 complétées / 8 totales (Phase 1-3)
- **Fichiers modifiés**: 6
- **Bloquants rencontrés**: 1 (pattern AG-Grid)

---

## 🎯 Pour la prochaine session

- Phase 4 (filtres) peut probablement aller direct au Dev
- Phase 5 (Orchestrator) aura besoin d'un Lead (intégration complexe)
- Penser à ajouter des tests pour QuotesCache
```

---

## Tracelog

Quand le MODE ANALYSE est utilisé, ajouter une entrée :

```markdown
## [2025-01-14 11:30] ANALYZE 📋 - Rétrospective session

**Contexte**: Fin de session SQUAD Phases 1-3
**Fichier**: analyse_1.md
**Points clés**:
- Lead utile pour Phase 3
- Friction: quand utiliser Lead vs Dev
- Suggestion: context budget pour PO
```

---

## Intégration avec les autres modes

Le MODE ANALYSE est **transversal** - il peut être utilisé après n'importe quel mode :

```
shapes_raw.md ─────┐
                   ├──→ analyse_raw.md
squad_raw.md ──────┘
  (avec ou sans --lead)
```

Les feedbacks capturés peuvent ensuite être utilisés pour améliorer les modes eux-mêmes.

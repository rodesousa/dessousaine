# Analyse de session

**Fichier**: analyse_0.md
**Date**: 2026-01-18
**SHAPE**: samuser
**Mode utilisé**: SQUAD --lead (MODE LEAD)
**Agent**: 📋 PO (avec reprise manuelle après blocage Lead)
**Durée estimée**: ~30 minutes

---

## Résumé de la session

Implémentation complète du module samuser (expositions des musées de Strasbourg). Le Lead a créé tous les fichiers (backend, tests, LiveView) mais a été bloqué sur les permissions `Bash` et `WebFetch`. Reprise manuelle pour validation (compile, tests, vérification scraping).

---

## ✅ Ce qui a bien fonctionné

- Le SHAPE a bien cadré le travail (spec claire, décisions figées)
- Le Lead a créé tous les fichiers en autonomie malgré les blocages
- Les sélecteurs génériques de fallback ont permis un scraping fonctionnel
- Le pattern cine_die était bien documenté et facile à reproduire
- La séparation PO/Lead/Dev était claire
- 6 tests passent, 9 expositions scrapées

---

## ⚠️ Difficultés rencontrées

### Permissions manquantes en background

**Contexte**: Le Lead (agent background) n'avait pas accès à `Bash` et `WebFetch`
**Impact**: Impossible de valider le code (`mix compile`, `mix test`) et de vérifier la structure HTML du site
**Contournement**: Reprise manuelle par le PO pour exécuter ces commandes

### Sélecteurs HTML incorrects dans la spec

**Contexte**: Les sélecteurs `.slider`, `.swiper-slide`, `.visit`, `a.event-thumbnail` n'existaient pas sur le site réel
**Impact**: Le Lead ne pouvait pas valider les sélecteurs (WebFetch bloqué)
**Contournement**: Le Lead a implémenté des sélecteurs génériques de fallback (`h2`, `h3`, `.date`, `.tag`) qui ont fonctionné

---

## 🔧 Frictions avec les modes

### Agents background sans permissions interactives

**Mode concerné**: lead_raw.md
**Description**: Les agents lancés avec `run_in_background: true` ne peuvent pas demander de permissions à l'utilisateur. `Bash`, `WebFetch` et autres outils nécessitant une approbation sont auto-denied.
**Suggestion**:
1. Documenter cette limitation dans lead_raw.md
2. Proposer un fichier `.claude/settings.local.json` avec des permissions pré-approuvées pour les commandes courantes (mix compile, mix test, etc.)
3. Ou utiliser `allowedPrompts` dans ExitPlanMode pour pré-approuver les commandes

### Pas de mécanisme de "handoff" Lead → PO

**Mode concerné**: lead_raw.md
**Description**: Quand le Lead est bloqué, il n'y a pas de protocole clair pour reprendre la main
**Suggestion**: Ajouter une section "En cas de blocage" avec le workflow de reprise

---

## 💡 Suggestions d'amélioration

### S1 - Fichier de permissions pour agents background

**Problème**: Les agents background sont bloqués sur les commandes courantes
**Proposition**: Créer un template `.claude/settings.local.json` avec :
```json
{
  "permissions": {
    "allow": [
      "Bash(mix compile)",
      "Bash(mix test*)",
      "Bash(mix format)",
      "WebFetch(*)"
    ]
  }
}
```
**Priorité**: Haute

### S2 - Documenter les limitations des agents background

**Problème**: On découvre les blocages en cours de session
**Proposition**: Ajouter dans lead_raw.md une section "Limitations connues" :
- `Bash` : nécessite permissions ou allowedPrompts
- `WebFetch` : nécessite permissions
- Les agents ne peuvent pas demander de permissions interactives
**Priorité**: Haute

### S3 - Template de prompt Lead avec pré-validation

**Problème**: Le Lead a créé du code sans pouvoir le valider
**Proposition**: Le prompt Lead devrait inclure une étape finale "Signale les validations à faire par le PO"
**Priorité**: Moyenne

### S4 - Vérifier les sélecteurs HTML avant de lancer le Lead

**Problème**: On a spécifié des sélecteurs incorrects dans la spec
**Proposition**: En phase SHAPE, valider les sélecteurs avec WebFetch avant de passer en READY
**Priorité**: Basse (cas spécifique scraping)

---

## 📊 Métriques

- **Tokens consommés Lead**: ~66k (avant arrêt)
- **Tokens consommés PO (reprise)**: ~15k
- **Nombre de tâches**: 9 complétées / 9 totales
- **Fichiers créés**: 7
- **Tests**: 6 passent
- **Bloquants rencontrés**: 2 (Bash permission, WebFetch permission)

---

## 🎯 Pour la prochaine session

1. **Pré-configurer les permissions** avant de lancer un Lead en background
2. **Valider les sélecteurs HTML** en phase SHAPE (pas en phase implémentation)
3. Pour ajouter un nouveau musée (provider), suivre le pattern de `musee_zoo.ex`
4. Les sélecteurs génériques fonctionnent bien - pas besoin de sélecteurs spécifiques par musée
5. Penser à ajouter la route dans le router Phoenix pour accéder à la LiveView

# Elixir Standard

Standards et patterns pour résoudre les problèmes de code en Elixir.

---

## Principe

Ce document capture les **patterns de résolution** découverts au fil du développement.
Chaque section documente un problème rencontré, la solution choisie, et pourquoi.

L'objectif : éviter de refaire les mêmes erreurs et avoir une référence rapide.

---

## Ecto & JSONB

### Problème : Mixed keys (atoms vs strings)

**Symptôme :**
```
** (Ecto.CastError) expected params to be a map with atoms or string keys,
got a map with mixed keys: %{:status => "pending", "payload" => %{...}}
```

**Cause :**
Après un `Repo.insert` ou `Repo.update`, l'objet retourné garde les clés telles qu'elles étaient en mémoire (atoms). PostgreSQL stocke le JSONB avec des clés strings, mais l'objet Elixir n'est pas rechargé automatiquement.

```elixir
# Insertion avec clés atoms
{:ok, analysis} = Repo.insert(%{metadata: %{status: "pending"}})

# analysis.metadata a encore des clés atoms !
analysis.metadata[:status]   # => "pending"
analysis.metadata["status"]  # => nil  ❌
```

**Solution : Reload after mutation**

```elixir
defp update_after_tools(analysis, tool_results) do
  # Reload from DB to ensure consistent string keys in metadata (JSONB)
  analysis = Repo.get!(Node, analysis.id)
  current_metadata = analysis.metadata
  # Maintenant current_metadata["payload"] fonctionne
  ...
end
```

**Pourquoi `Repo.get!` plutôt que `stringify_keys` ?**

| Critère | `stringify_keys` | `Repo.get!` |
|---------|------------------|-------------|
| Requêtes DB | 0 | +1 |
| Cohérence | Défensif, masque le problème | Données à jour |
| Triggers DB | Non appliqués | Appliqués |
| Valeurs par défaut | Non récupérées | Récupérées |
| Maintenabilité | Doit penser à stringify partout | Pattern standard |

**Règle :** Toujours recharger une entité depuis la DB si tu vas la réutiliser après une mutation.

---

### Problème : Clés inconsistantes dans les maps JSONB

**Symptôme :**
Tu crées une map avec des clés atoms, mais plus tard tu accèdes avec des clés strings.

**Solution : Utiliser des clés strings dès la création**

```elixir
# ❌ Mauvais - mélange de conventions
payload: %{
  tools: %{
    methodology: %{
      detected_themes: themes
    }
  }
}

# ✅ Bon - cohérent avec le stockage JSONB
payload: %{
  "tools" => %{
    "methodology" => %{
      "detected_themes" => stringify_keys(themes)
    }
  }
}
```

**Helper utile :**

```elixir
defp stringify_keys(map) when is_map(map) do
  Map.new(map, fn {k, v} -> {to_string(k), stringify_keys(v)} end)
end

defp stringify_keys(list) when is_list(list) do
  Enum.map(list, &stringify_keys/1)
end

defp stringify_keys(value), do: value
```

---

## Pattern Matching

### Problème : Clause qui ne match jamais

**Symptôme :**
```
warning: the following clause will never match:
    {:error, reason}
because it attempts to match on the result of:
    some_function()
which has type:
    dynamic((term(), term() -> term()))
```

**Cause :**
La fonction retourne une fonction (souvent un stream), pas directement `{:ok, _}` ou `{:error, _}`.

**Solution :**
Vérifier le type de retour de la fonction. Si c'est un stream, il faut le consommer différemment.

---

## Oban Workers

### Pattern : Vérifier les prérequis avant exécution

Quand un worker async dépend d'un état préalable, vérifier explicitement :

```elixir
def perform(%Oban.Job{args: %{"analysis_id" => id}}) do
  with {:ok, analysis} <- get_analysis(id),
       :ok <- verify_status_complete(analysis),  # Guard clause
       {:ok, result} <- do_work(analysis) do
    :ok
  end
end

# Pattern matching multi-clause pour la vérification
defp verify_status_complete(%Node{metadata: %{"status" => "complete"}}), do: :ok

defp verify_status_complete(%Node{metadata: %{"status" => status}}) do
  Logger.warning("Expected 'complete', got '#{status}'")
  {:error, :invalid_status}
end

defp verify_status_complete(_), do: {:error, :missing_status}
```

**Pourquoi ?**
- Le job async peut être déclenché alors que l'étape précédente a échoué
- Fail fast avec un message clair plutôt que des erreurs cryptiques
- Permet le retry intelligent (Oban réessaiera si c'est un problème transitoire)

---

## Debugging

### Pattern : Logger structuré avec emojis

Pour les pipelines multi-étapes, utiliser des emojis distinctifs :

```elixir
Logger.info("⏱️  Turn 1 completed in #{time}s")
Logger.info("💾 SAVE #1: Analysis #{id} saved with status 'pending'")
Logger.error("❌ Turn 2 failed: #{inspect(reason)}")
```

Permet de scanner rapidement les logs et identifier les étapes.

---

## Conventions de nommage

### Fonctions privées de transformation

| Préfixe | Usage | Exemple |
|---------|-------|---------|
| `normalize_` | Convertir un format vers un autre | `normalize_tool_calls/1` |
| `stringify_` | Convertir les clés en strings | `stringify_keys/1` |
| `build_` | Construire une structure complexe | `build_prompt/1` |
| `get_` | Récupérer depuis DB/cache | `get_analysis/1` |
| `verify_` | Vérifier une condition, retourne `:ok` ou `{:error, _}` | `verify_status_complete/1` |
| `mark_as_` | Changer un état | `mark_as_failed/2` |

---

## Anti-patterns à éviter

### 1. Accéder aux clés JSONB sans vérifier le type

```elixir
# ❌ Dangereux - peut échouer silencieusement
metadata["payload"]["tools"]

# ✅ Défensif
current_payload = metadata["payload"] || %{}
current_tools = current_payload["tools"] || %{}
```

### 2. Réutiliser un objet après mutation sans reload

```elixir
# ❌ L'objet en mémoire peut être stale
{:ok, analysis} = save_analysis(attrs)
update_analysis(analysis, new_data)  # analysis.metadata a des clés atoms!

# ✅ Toujours recharger
{:ok, analysis} = save_analysis(attrs)
analysis = Repo.get!(Node, analysis.id)
update_analysis(analysis, new_data)
```

### 3. Ignorer les erreurs dans un pipeline

```elixir
# ❌ L'erreur est masquée
case do_something() do
  {:ok, result} -> process(result)
  {:error, _} -> nil  # Silencieux
end

# ✅ Propager ou logger
case do_something() do
  {:ok, result} -> process(result)
  {:error, reason} = error ->
    Logger.error("Failed: #{inspect(reason)}")
    error
end
```

---

## Checklist avant commit

- [ ] Les maps destinées au JSONB utilisent des clés strings
- [ ] Les objets sont rechargés après mutation si réutilisés
- [ ] Les workers async vérifient leurs prérequis
- [ ] Les erreurs sont loggées avec contexte
- [ ] Le code compile sans nouveaux warnings


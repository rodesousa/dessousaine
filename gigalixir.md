# Deploiement Gigalixir - CineDie

## Prerequis

- Compte Gigalixir : https://www.gigalixir.com/
- CLI Gigalixir installe : `pip install gigalixir`
- Authentification : `gigalixir login`

## 1. Creer l'application Gigalixir

```bash
gigalixir create -n cinedie
```

## 2. Creer la base de donnees

```bash
gigalixir pg:create --free -a cinedie
```

> **Note** : Free tier non recommande pour la production. La migration vers un tier standard n'est pas triviale.

## 3. Fichiers de configuration

### `.buildpacks`

```
https://github.com/gigalixir/gigalixir-buildpack-elixir
https://github.com/gigalixir/gigalixir-buildpack-phoenix-static
```

> **Erreur corrigee** : Les anciens buildpacks `heroku-buildpack-elixir` et `heroku-buildpack-phoenix-static` sont EOL (End of Life). Utiliser les buildpacks Gigalixir.

### `elixir_buildpack.config`

```
elixir_version=1.18.1
erlang_version=27.2.1
```

### `phoenix_static_buildpack.config`

```
node_version=20.11.0
```

### `Procfile`

```
web: bin/server
```

### `assets/package.json`

```json
{
  "scripts": {
    "deploy": "cd .. && mix assets.deploy && rm -f _build/esbuild*"
  }
}
```

### `rel/env.sh.eex`

```bash
#!/bin/sh
export PHX_SERVER=true
```

> **Erreur corrigee** : Sans `PHX_SERVER=true`, l'endpoint Phoenix ne demarre pas en mode release.

### `config/runtime.exs` - Configuration SSL

```elixir
config :cine_die, CineDie.Repo,
  ssl: true,
  ssl_opts: [verify: :verify_none],
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  socket_options: maybe_ipv6
```

> **Erreur corrigee** : Les bases Gigalixir requierent SSL. Sans `ssl: true` et `ssl_opts: [verify: :verify_none]`, la connexion echoue.

### `lib/cine_die/release.ex`

Module pour executer les migrations en production sans Mix :

```elixir
defmodule CineDie.Release do
  @app :cine_die

  def migrate do
    load_app()
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos, do: Application.fetch_env!(@app, :ecto_repos)
  defp load_app, do: Application.load(@app)
end
```

## 4. Generer les fichiers de release Phoenix

```bash
mix phx.gen.release --no-ecto
```

Cela cree `rel/overlays/bin/server` qui active automatiquement `PHX_SERVER=true`.

## 5. Configurer SECRET_KEY_BASE

```bash
# Generer une cle
mix phx.gen.secret

# Configurer sur Gigalixir
gigalixir config:set SECRET_KEY_BASE="<valeur_generee>" -a cinedie
```

## 6. Lier le repo local a Gigalixir

```bash
# Ajouter le remote Gigalixir
gigalixir git:remote cinedie

# Ou manuellement
git remote add gigalixir https://git.gigalixir.com/cinedie.git

# Verifier les remotes
git remote -v
# origin     git@github.com:rodesousa/cine_die.git (GitHub)
# gigalixir  https://git.gigalixir.com/cinedie.git (Gigalixir)
```

## 7. Deployer

```bash
git add -A
git commit -m "Setup Gigalixir deployment"
git push gigalixir master
```

## 8. Executer les migrations

Apres le deploiement :

```bash
gigalixir run mix ecto.migrate -a cinedie
```

Cela cree :
- Tables Oban (`oban_jobs`, `oban_peers`, etc.)
- Table `weekly_schedules`

## Commandes utiles

```bash
# Voir les logs
gigalixir logs -a cinedie

# Voir le statut de l'app
gigalixir ps -a cinedie

# Ouvrir une console IEx distante
gigalixir ps:remote_console -a cinedie

# Voir les variables d'environnement
gigalixir config -a cinedie

# Redemarrer l'app
gigalixir ps:restart -a cinedie
```

## Erreurs rencontrees et solutions

| Erreur | Cause | Solution |
|--------|-------|----------|
| `Configuration :server was not enabled` | PHX_SERVER non defini | Creer `rel/env.sh.eex` avec `export PHX_SERVER=true` |
| `password authentication failed for user` | SSL non configure | Ajouter `ssl: true, ssl_opts: [verify: :verify_none]` dans runtime.exs |
| `EOL NOTICE` buildpack | Buildpacks Heroku obsoletes | Utiliser les buildpacks `gigalixir/gigalixir-buildpack-*` |
| `Deploy aborted` | Buildpack EOL | Mettre a jour `.buildpacks` |

## Architecture du deploiement

```
Local Git Repo
     |
     +---> git push origin master    ---> GitHub (backup code)
     |
     +---> git push gigalixir master ---> Gigalixir (deploiement)
                                              |
                                              v
                                         Build & Deploy
                                              |
                                              v
                                         PostgreSQL (DATABASE_URL auto-configure)
```

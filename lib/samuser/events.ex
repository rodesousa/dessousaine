defmodule Samuser.Events do
  @moduledoc """
  Contexte pour gérer les events des musées.

  Les events sont stockés en base de données pour éviter de refaire
  le scraping à chaque refresh. Le checksum permet de détecter les doublons.
  """
  import Ecto.Query
  alias Dessousaine.Repo
  alias Samuser.Events.Event
  alias Samuser.Providers.Provider

  @pubsub Dessousaine.PubSub
  @topic "samuser_events"

  @providers %{
    museezoo: Samuser.Providers.MuseeZoo,
    aubette: Samuser.Providers.Aubette,
    tomi_ungerer: Samuser.Providers.TomiUngerer,
    oeuvre_notre_dame: Samuser.Providers.OeuvreNotreDame,
    art_moderne: Samuser.Providers.ArtModerne,
    historique: Samuser.Providers.Historique,
    alsacien: Samuser.Providers.Alsacien,
    arts_decoratifs: Samuser.Providers.ArtsDecoratifs,
    beaux_arts: Samuser.Providers.BeauxArts,
    archeologique: Samuser.Providers.Archeologique
  }

  @doc """
  Liste tous les events depuis la DB, triés par date d'ajout (récents en premier).
  """
  def list_all do
    Event
    |> order_by([e], desc: e.inserted_at)
    |> Repo.all()
    |> Enum.map(&event_to_map/1)
  end

  @doc """
  Liste les events d'un musée spécifique depuis la DB.
  """
  def list_by_museum(provider_key) when is_atom(provider_key) do
    Event
    |> where([e], e.provider == ^provider_key)
    |> order_by([e], desc: e.inserted_at)
    |> Repo.all()
    |> Enum.map(&event_to_map/1)
  end

  @doc """
  Synchronise les events d'un provider: scrape + upsert en DB.
  Supprime les events qui n'existent plus sur le site.
  Retourne {:ok, %{inserted: n, deleted: m}}.
  """
  def sync_provider(provider_key) when is_atom(provider_key) do
    case Map.get(@providers, provider_key) do
      nil ->
        {:error, :unknown_provider}

      module ->
        case Provider.fetch_and_validate(module) do
          {:ok, data} ->
            museum_name = data["metadata"]["museum_name"]
            events = data["events"]

            # Calculer les checksums des events scrapés
            new_checksums =
              events
              |> Enum.map(&Event.compute_checksum/1)
              |> MapSet.new()

            # Récupérer les checksums actuels en DB
            old_checksums =
              Event
              |> where([e], e.provider == ^provider_key)
              |> select([e], e.checksum)
              |> Repo.all()
              |> MapSet.new()

            # Supprimer les events qui n'existent plus
            to_delete = MapSet.difference(old_checksums, new_checksums)

            deleted_count =
              if MapSet.size(to_delete) > 0 do
                {count, _} =
                  Event
                  |> where([e], e.provider == ^provider_key)
                  |> where([e], e.checksum in ^MapSet.to_list(to_delete))
                  |> Repo.delete_all()

                count
              else
                0
              end

            # Upsert les nouveaux/modifiés
            inserted_count =
              events
              |> Enum.map(&upsert_event(provider_key, museum_name, &1))
              |> Enum.count(fn result -> match?({:ok, _}, result) end)

            broadcast_update(provider_key)
            {:ok, %{inserted: inserted_count, deleted: deleted_count}}

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  @doc """
  Synchronise tous les providers en parallèle.
  """
  def sync_all do
    @providers
    |> Map.keys()
    |> Task.async_stream(&sync_provider/1, timeout: 60_000, on_timeout: :kill_task)
    |> Enum.map(fn
      {:ok, result} -> result
      {:exit, _reason} -> {:error, :timeout}
    end)
  end

  @doc """
  Upsert un event en DB.
  """
  def upsert_event(provider_key, museum_name, event_data) do
    checksum = Event.compute_checksum(event_data)

    attrs = %{
      provider: provider_key,
      title: event_data["title"],
      date: event_data["date"],
      tag: event_data["tag"],
      photo_url: event_data["photo_url"],
      url: event_data["url"],
      museum_name: museum_name,
      checksum: checksum
    }

    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert(
      on_conflict: {:replace, [:date, :tag, :photo_url, :url, :updated_at]},
      conflict_target: [:provider, :checksum]
    )
  end

  @doc """
  Subscribe aux mises à jour.
  """
  def subscribe do
    Phoenix.PubSub.subscribe(@pubsub, @topic)
  end

  @doc """
  Retourne la liste des providers disponibles.
  """
  def available_providers do
    @providers
    |> Enum.map(fn {key, module} ->
      info = module.museum_info()
      %{key: key, name: info.name, url: info.url}
    end)
  end

  @doc """
  Compte le nombre total d'events en DB.
  """
  def count_events do
    Repo.aggregate(Event, :count)
  end

  @doc """
  Supprime tous les events d'un provider.
  """
  def delete_by_provider(provider_key) when is_atom(provider_key) do
    Event
    |> where([e], e.provider == ^provider_key)
    |> Repo.delete_all()
  end

  defp broadcast_update(provider_key) do
    Phoenix.PubSub.broadcast(@pubsub, @topic, {:events_updated, provider_key})
  end

  defp event_to_map(%Event{} = event) do
    %{
      "title" => event.title,
      "date" => event.date,
      "tag" => event.tag,
      "photo_url" => event.photo_url,
      "url" => event.url,
      "museum_name" => event.museum_name,
      "inserted_at" => event.inserted_at
    }
  end
end

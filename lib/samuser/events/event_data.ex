defmodule Samuser.Events.EventData do
  @moduledoc """
  Schema de validation pour les donnees d'events de musees.

  Ce module utilise des embedded schemas Ecto pour valider la structure
  des donnees. La fonction `validate/1` retourne un map pur (sans structs).

  ## Structure attendue

      %{
        "events" => [
          %{
            "title" => "Nom de l'event",
            "date" => "15 aout 2024 - 31 janv. 2025",  # string brute, peut etre nil
            "tag" => "visite",                          # optionnel
            "photo_url" => "https://...",               # optionnel
            "url" => "https://..."                      # optionnel
          }
        ],
        "metadata" => %{
          "museum_name" => "Musee Zoologique",
          "museum_url" => "https://...",
          "total_events" => 3,
          "fetched_at" => "2026-01-18T10:00:00Z"
        }
      }
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    embeds_many :events, Event, primary_key: false do
      field :title, :string
      field :date, :string
      field :tag, :string
      field :photo_url, :string
      field :url, :string
    end

    embeds_one :metadata, Metadata, primary_key: false do
      field :museum_name, :string
      field :museum_url, :string
      field :total_events, :integer
      field :fetched_at, :string
    end
  end

  @doc """
  Valide les donnees d'events et retourne un map pur (sans structs).

  ## Exemples

      iex> data = %{"events" => [...], "metadata" => %{...}}
      iex> {:ok, validated} = EventData.validate(data)
      iex> is_map(validated)
      true

  """
  @spec validate(map()) :: {:ok, map()} | {:error, Ecto.Changeset.t()}
  def validate(data) when is_map(data) do
    changeset = changeset(%__MODULE__{}, data)

    if changeset.valid? do
      {:ok, to_map(changeset)}
    else
      {:error, changeset}
    end
  end

  defp changeset(struct, params) do
    struct
    |> cast(params, [])
    |> cast_embed(:events, required: false, with: &event_changeset/2)
    |> cast_embed(:metadata, required: true, with: &metadata_changeset/2)
    |> validate_events_not_nil()
  end

  defp validate_events_not_nil(changeset) do
    case get_field(changeset, :events) do
      nil -> add_error(changeset, :events, "can't be nil")
      _ -> changeset
    end
  end

  defp event_changeset(struct, params) do
    struct
    |> cast(params, [:title, :date, :tag, :photo_url, :url])
    |> validate_required([:title])
  end

  defp metadata_changeset(struct, params) do
    struct
    |> cast(params, [:museum_name, :museum_url, :total_events, :fetched_at])
    |> validate_required([:museum_name])
  end

  @doc """
  Convertit un changeset valide en map pur (sans structs).
  """
  def to_map(changeset) do
    data = apply_changes(changeset)

    %{
      "events" => Enum.map(data.events, &event_to_map/1),
      "metadata" => metadata_to_map(data.metadata)
    }
  end

  defp event_to_map(event) do
    %{
      "title" => event.title,
      "date" => event.date,
      "tag" => event.tag,
      "photo_url" => event.photo_url,
      "url" => event.url
    }
  end

  defp metadata_to_map(metadata) do
    %{
      "museum_name" => metadata.museum_name,
      "museum_url" => metadata.museum_url,
      "total_events" => metadata.total_events,
      "fetched_at" => metadata.fetched_at
    }
  end
end

defmodule Samuser.Events.Event do
  @moduledoc """
  Schema Ecto pour stocker les events des musées de Strasbourg.

  Chaque event est stocké dans une ligne séparée, ce qui permet:
  - Tri par `inserted_at` (events récents en premier)
  - Queries simples sur les champs individuels
  - Unique constraint sur `provider + checksum` pour éviter les doublons
  """
  use Ecto.Schema
  import Ecto.Changeset

  @providers [
    :museezoo,
    :aubette,
    :tomi_ungerer,
    :oeuvre_notre_dame,
    :art_moderne,
    :historique,
    :alsacien,
    :arts_decoratifs,
    :beaux_arts,
    :archeologique
  ]

  schema "samuser_events" do
    field :provider, Ecto.Enum, values: @providers
    field :title, :string
    field :date, :string
    field :tag, :string
    field :photo_url, :string
    field :url, :string
    field :museum_name, :string
    field :checksum, :string

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset pour créer ou mettre à jour un event.
  """
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:provider, :title, :date, :tag, :photo_url, :url, :museum_name, :checksum])
    |> validate_required([:provider, :title, :museum_name, :checksum])
    |> unique_constraint([:provider, :checksum])
  end

  @doc """
  Calcule le checksum SHA256 d'un event basé sur son contenu.
  """
  def compute_checksum(%{"title" => title, "date" => date, "tag" => tag, "url" => url}) do
    content = "#{title}|#{date}|#{tag}|#{url}"

    :crypto.hash(:sha256, content)
    |> Base.encode16(case: :lower)
  end
end

defmodule Samuser.Providers.Provider do
  @moduledoc """
  Behaviour commun pour tous les providers de musees.

  CHAQUE provider DOIT implementer :
  - `fetch_raw/0` : Recupere les donnees brutes (HTML)
  - `to_event_data/1` : Transforme les donnees brutes en format EventData
  - `museum_info/0` : Retourne les infos du musee
  """

  alias Samuser.Events.EventData

  @type raw_data :: term()
  @type museum_info :: %{name: String.t(), url: String.t(), provider: atom()}

  @callback fetch_raw() :: {:ok, raw_data()} | {:error, term()}
  @callback to_event_data(raw_data()) :: {:ok, map()} | {:error, term()}
  @callback museum_info() :: museum_info()

  @doc """
  Pipeline complet : fetch -> transform -> validate
  Retourne {:ok, validated_map} ou {:error, reason}
  """
  def fetch_and_validate(provider_module) do
    with {:ok, raw} <- provider_module.fetch_raw(),
         {:ok, data} <- provider_module.to_event_data(raw),
         {:ok, validated} <- EventData.validate(data) do
      {:ok, validated}
    end
  end

  @doc "Calcule le checksum SHA256 des donnees"
  def compute_checksum(data) do
    data
    |> Jason.encode!()
    |> then(&:crypto.hash(:sha256, &1))
    |> Base.encode16(case: :lower)
  end
end

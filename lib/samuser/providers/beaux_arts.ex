defmodule Samuser.Providers.BeauxArts do
  @moduledoc """
  Provider pour le Musée des Beaux-Arts.
  """

  @behaviour Samuser.Providers.Provider

  @base_url "https://www.musees.strasbourg.eu"
  @page_url "#{@base_url}/web/musees/musee-des-beaux-arts"

  @impl true
  def museum_info do
    %{name: "Musee des Beaux-Arts", url: @page_url, provider: :beaux_arts}
  end

  @impl true
  def fetch_raw do
    case Req.get(@page_url, receive_timeout: 30_000) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, %{status: status}} -> {:error, {:http_error, status}}
      {:error, reason} -> {:error, reason}
    end
  end

  @impl true
  def to_event_data(html) when is_binary(html) do
    doc = Floki.parse_document!(html)
    info = museum_info()

    events =
      doc
      |> Floki.find(".swiper-wrapper a.event-thumbnail")
      |> Enum.map(&parse_event/1)
      |> Enum.reject(&is_nil/1)

    {:ok, %{
      "events" => events,
      "metadata" => %{
        "museum_name" => info.name,
        "museum_url" => info.url,
        "total_events" => length(events),
        "fetched_at" => DateTime.utc_now() |> DateTime.to_iso8601()
      }
    }}
  end

  defp parse_event(element) do
    title = element |> Floki.find(".title") |> Floki.text() |> String.trim()
    if title == "", do: nil, else: %{
      "title" => title,
      "date" => element |> Floki.find(".dates") |> Floki.text() |> String.trim() |> nilify(),
      "tag" => element |> Floki.find(".visit") |> Floki.text() |> String.trim() |> nilify(),
      "photo_url" => extract_photo_url(element),
      "url" => element |> Floki.attribute("href") |> List.first() |> maybe_absolute_url()
    }
  end

  defp nilify(""), do: nil
  defp nilify(s), do: s

  defp extract_photo_url(element) do
    case element |> Floki.attribute("style") |> List.first() do
      nil -> nil
      style ->
        case Regex.run(~r/background-image: url\(([^)]+)\)/, style) do
          [_, url] -> url
          _ -> nil
        end
    end
  end

  defp maybe_absolute_url(nil), do: nil
  defp maybe_absolute_url(url) when is_binary(url) do
    if String.starts_with?(url, "http"), do: url, else: @base_url <> url
  end
end

defmodule Samuser.Providers.MuseeZoo do
  @moduledoc """
  Provider pour le Musee Zoologique de Strasbourg.
  Scrape la page principale pour lister les events.
  """

  @behaviour Samuser.Providers.Provider

  require Logger

  @base_url "https://www.musees.strasbourg.eu"
  @page_url "#{@base_url}/web/musees/musee-zoologique"

  @impl true
  def museum_info do
    %{name: "Musee Zoologique", url: @page_url, provider: :museezoo}
  end

  @impl true
  def fetch_raw do
    case Req.get(@page_url, receive_timeout: 30_000) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %{status: status}} ->
        {:error, {:http_error, status}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def to_event_data(html) when is_binary(html) do
    doc = Floki.parse_document!(html)
    info = museum_info()

    # Chercher les events dans le swiper-wrapper
    events =
      doc
      |> find_event_elements()
      |> Enum.map(&parse_event/1)
      |> Enum.reject(&is_nil/1)

    data = %{
      "events" => events,
      "metadata" => %{
        "museum_name" => info.name,
        "museum_url" => info.url,
        "total_events" => length(events),
        "fetched_at" => DateTime.utc_now() |> DateTime.to_iso8601()
      }
    }

    {:ok, data}
  end

  # Trouve les elements d'events dans le swiper-wrapper
  defp find_event_elements(doc) do
    Floki.find(doc, ".swiper-wrapper a.event-thumbnail")
  end

  # Parse un element d'event
  defp parse_event(element) do
    title = extract_title(element)

    # Si pas de titre, ignorer cet event
    if is_nil(title) or title == "" do
      nil
    else
      %{
        "title" => title,
        "date" => extract_date(element),
        "tag" => extract_tag(element),
        "photo_url" => extract_photo_url(element),
        "url" => extract_url(element)
      }
    end
  end

  defp extract_title(element) do
    # Chercher le titre dans differents emplacements
    selectors = [
      "h2",
      "h3",
      ".title",
      ".event-title",
      "a[title]"
    ]

    Enum.find_value(selectors, fn selector ->
      case Floki.find(element, selector) do
        [] ->
          nil

        found ->
          text = Floki.text(found) |> String.trim()
          if text != "", do: text, else: nil
      end
    end)
  end

  defp extract_date(element) do
    # Chercher la date dans differents emplacements
    selectors = [
      ".date",
      ".dates",
      ".event-date",
      "time",
      "span.date"
    ]

    Enum.find_value(selectors, fn selector ->
      case Floki.find(element, selector) do
        [] ->
          nil

        found ->
          text = Floki.text(found) |> String.trim()
          if text != "", do: text, else: nil
      end
    end)
  end

  defp extract_tag(element) do
    # Chercher le tag "visit" ou similaire
    selectors = [
      ".visit",
      ".tag",
      ".category",
      ".type"
    ]

    Enum.find_value(selectors, fn selector ->
      case Floki.find(element, selector) do
        [] ->
          nil

        found ->
          text = Floki.text(found) |> String.trim()
          if text != "", do: text, else: nil
      end
    end)
  end

  defp extract_photo_url(element) do
    # L'element est deja le a.event-thumbnail, extraire le style directement
    element
    |> Floki.attribute("style")
    |> List.first()
    |> case do
      nil -> nil
      style ->
        case Regex.run(~r/background-image: url\(([^)]+)\)/, style) do
          [_, url] -> url
          _ -> nil
        end
    end
  end

  defp extract_url(element) do
    # L'element est deja le a.event-thumbnail, extraire href directement
    element
    |> Floki.attribute("href")
    |> List.first()
    |> maybe_absolute_url()
  end

  defp maybe_absolute_url(nil), do: nil

  defp maybe_absolute_url(url) do
    if String.starts_with?(url, "http") do
      url
    else
      @base_url <> url
    end
  end
end

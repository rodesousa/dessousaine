defmodule DessousaineWeb.SamuserLive do
  @moduledoc """
  LiveView pour afficher les events des musees de Strasbourg.
  """
  use DessousaineWeb, :live_view

  alias Samuser.Events

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Events.subscribe()
    end

    socket =
      socket
      |> assign(:page_title, "Expos Strasbourg")
      |> assign(:loading, false)
      |> assign(:selected_museums, MapSet.new())
      |> assign(:events, [])
      |> assign(:all_events, [])
      |> assign(:error, nil)

    socket =
      if connected?(socket) do
        load_events(socket)
      else
        socket
      end

    {:ok, socket}
  end

  @impl true
  def handle_event("toggle_museum", %{"museum" => museum}, socket) do
    museum_atom = String.to_existing_atom(museum)

    selected =
      if MapSet.member?(socket.assigns.selected_museums, museum_atom) do
        MapSet.delete(socket.assigns.selected_museums, museum_atom)
      else
        MapSet.put(socket.assigns.selected_museums, museum_atom)
      end

    socket =
      socket
      |> assign(:selected_museums, selected)
      |> filter_events()

    {:noreply, socket}
  end

  @impl true
  def handle_event("refresh", _, socket) do
    send(self(), :do_sync)
    {:noreply, assign(socket, :loading, true)}
  end

  @impl true
  def handle_info(:do_sync, socket) do
    # Sync tous les providers puis reload depuis la DB
    Events.sync_all()
    socket = load_events(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:events_updated, _provider}, socket) do
    # Un provider a été mis à jour, on recharge depuis la DB
    socket = load_events(socket)
    {:noreply, socket}
  end

  defp load_events(socket) do
    try do
      events = Events.list_all()

      socket
      |> assign(:all_events, events)
      |> assign(:loading, false)
      |> assign(:error, nil)
      |> filter_events()
    rescue
      e ->
        socket
        |> assign(:loading, false)
        |> assign(:error, Exception.message(e))
        |> assign(:events, [])
    end
  end

  defp filter_events(%{assigns: assigns} = socket) do
    selected_names =
      assigns.selected_museums
      |> MapSet.to_list()
      |> Enum.map(&museum_name/1)

    filter_active? = selected_names != []

    events =
      (assigns[:all_events] || [])
      |> Enum.filter(fn event ->
        # Si aucun filtre actif, tout inclure; sinon filtrer
        not filter_active? or event["museum_name"] in selected_names
      end)

    assign(socket, :events, events)
  end

  defp all_museum_keys do
    available_museums()
    |> Enum.map(& &1.key)
    |> MapSet.new()
  end

  defp museum_name(:museezoo), do: "Musee Zoologique"
  defp museum_name(:aubette), do: "Aubette 1928"
  defp museum_name(:tomi_ungerer), do: "Musee Tomi Ungerer"
  defp museum_name(:oeuvre_notre_dame), do: "Musee de l'Oeuvre Notre-Dame"
  defp museum_name(:art_moderne), do: "Musee d'Art moderne et contemporain"
  defp museum_name(:historique), do: "Musee Historique"
  defp museum_name(:alsacien), do: "Musee Alsacien"
  defp museum_name(:arts_decoratifs), do: "Musee des Arts Decoratifs"
  defp museum_name(:beaux_arts), do: "Musee des Beaux-Arts"
  defp museum_name(:archeologique), do: "Musee Archeologique"

  @doc """
  Returns the available museums for the UI.
  """
  def available_museums do
    [
      %{key: :museezoo, name: "Musee Zoologique"},
      %{key: :aubette, name: "Aubette 1928"},
      %{key: :tomi_ungerer, name: "Musee Tomi Ungerer"},
      %{key: :oeuvre_notre_dame, name: "Musee de l'Oeuvre Notre-Dame"},
      %{key: :art_moderne, name: "MAMCS"},
      %{key: :historique, name: "Musee Historique"},
      %{key: :alsacien, name: "Musee Alsacien"},
      %{key: :arts_decoratifs, name: "Arts Decoratifs"},
      %{key: :beaux_arts, name: "Beaux-Arts"},
      %{key: :archeologique, name: "Archeologique"}
    ]
  end
end

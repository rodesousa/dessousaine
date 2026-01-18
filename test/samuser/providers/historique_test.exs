defmodule Samuser.Providers.HistoriqueTest do
  use ExUnit.Case, async: true
  alias Samuser.Providers.Historique
  alias Samuser.Events.EventData

  describe "museum_info/0" do
    test "returns museum info" do
      info = Historique.museum_info()
      assert info.name == "Musee Historique"
      assert info.provider == :historique
    end
  end

  describe "to_event_data/1" do
    @tag :external
    test "parses HTML into event data" do
      {:ok, html} = Historique.fetch_raw()
      assert {:ok, data} = Historique.to_event_data(html)
      assert {:ok, _} = EventData.validate(data)
    end

    test "handles empty HTML" do
      assert {:ok, data} = Historique.to_event_data("<html></html>")
      assert data["events"] == []
    end
  end
end

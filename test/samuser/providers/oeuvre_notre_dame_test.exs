defmodule Samuser.Providers.OeuvreNotreDameTest do
  use ExUnit.Case, async: true
  alias Samuser.Providers.OeuvreNotreDame
  alias Samuser.Events.EventData

  describe "museum_info/0" do
    test "returns museum info" do
      info = OeuvreNotreDame.museum_info()
      assert info.name == "Musee de l'Oeuvre Notre-Dame"
      assert info.provider == :oeuvre_notre_dame
    end
  end

  describe "to_event_data/1" do
    @tag :external
    test "parses HTML into event data" do
      {:ok, html} = OeuvreNotreDame.fetch_raw()
      assert {:ok, data} = OeuvreNotreDame.to_event_data(html)
      assert {:ok, _} = EventData.validate(data)
    end

    test "handles empty HTML" do
      assert {:ok, data} = OeuvreNotreDame.to_event_data("<html></html>")
      assert data["events"] == []
    end
  end
end

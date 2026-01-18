defmodule Samuser.Providers.ArtModerneTest do
  use ExUnit.Case, async: true
  alias Samuser.Providers.ArtModerne
  alias Samuser.Events.EventData

  describe "museum_info/0" do
    test "returns museum info" do
      info = ArtModerne.museum_info()
      assert info.name == "Musee d'Art moderne et contemporain"
      assert info.provider == :art_moderne
    end
  end

  describe "to_event_data/1" do
    @tag :external
    test "parses HTML into event data" do
      {:ok, html} = ArtModerne.fetch_raw()
      assert {:ok, data} = ArtModerne.to_event_data(html)
      assert {:ok, _} = EventData.validate(data)
    end

    test "handles empty HTML" do
      assert {:ok, data} = ArtModerne.to_event_data("<html></html>")
      assert data["events"] == []
    end
  end
end

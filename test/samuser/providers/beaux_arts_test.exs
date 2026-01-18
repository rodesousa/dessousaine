defmodule Samuser.Providers.BeauxArtsTest do
  use ExUnit.Case, async: true
  alias Samuser.Providers.BeauxArts
  alias Samuser.Events.EventData

  describe "museum_info/0" do
    test "returns museum info" do
      info = BeauxArts.museum_info()
      assert info.name == "Musee des Beaux-Arts"
      assert info.provider == :beaux_arts
    end
  end

  describe "to_event_data/1" do
    @tag :external
    test "parses HTML into event data" do
      {:ok, html} = BeauxArts.fetch_raw()
      assert {:ok, data} = BeauxArts.to_event_data(html)
      assert {:ok, _} = EventData.validate(data)
    end

    test "handles empty HTML" do
      assert {:ok, data} = BeauxArts.to_event_data("<html></html>")
      assert data["events"] == []
    end
  end
end

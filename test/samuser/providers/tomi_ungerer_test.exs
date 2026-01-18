defmodule Samuser.Providers.TomiUngererTest do
  use ExUnit.Case, async: true
  alias Samuser.Providers.TomiUngerer
  alias Samuser.Events.EventData

  describe "museum_info/0" do
    test "returns museum info" do
      info = TomiUngerer.museum_info()
      assert info.name == "Musee Tomi Ungerer"
      assert info.provider == :tomi_ungerer
    end
  end

  describe "to_event_data/1" do
    @tag :external
    test "parses HTML into event data" do
      {:ok, html} = TomiUngerer.fetch_raw()
      assert {:ok, data} = TomiUngerer.to_event_data(html)
      assert {:ok, _} = EventData.validate(data)
    end

    test "handles empty HTML" do
      assert {:ok, data} = TomiUngerer.to_event_data("<html></html>")
      assert data["events"] == []
    end
  end
end

defmodule Samuser.Providers.ArcheologiqueTest do
  use ExUnit.Case, async: true
  alias Samuser.Providers.Archeologique
  alias Samuser.Events.EventData

  describe "museum_info/0" do
    test "returns museum info" do
      info = Archeologique.museum_info()
      assert info.name == "Musee Archeologique"
      assert info.provider == :archeologique
    end
  end

  describe "to_event_data/1" do
    @tag :external
    test "parses HTML into event data" do
      {:ok, html} = Archeologique.fetch_raw()
      assert {:ok, data} = Archeologique.to_event_data(html)
      assert {:ok, _} = EventData.validate(data)
    end

    test "handles empty HTML" do
      assert {:ok, data} = Archeologique.to_event_data("<html></html>")
      assert data["events"] == []
    end
  end
end

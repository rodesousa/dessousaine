defmodule Samuser.Providers.AlsacienTest do
  use ExUnit.Case, async: true
  alias Samuser.Providers.Alsacien
  alias Samuser.Events.EventData

  describe "museum_info/0" do
    test "returns museum info" do
      info = Alsacien.museum_info()
      assert info.name == "Musee Alsacien"
      assert info.provider == :alsacien
    end
  end

  describe "to_event_data/1" do
    @tag :external
    test "parses HTML into event data" do
      {:ok, html} = Alsacien.fetch_raw()
      assert {:ok, data} = Alsacien.to_event_data(html)
      assert {:ok, _} = EventData.validate(data)
    end

    test "handles empty HTML" do
      assert {:ok, data} = Alsacien.to_event_data("<html></html>")
      assert data["events"] == []
    end
  end
end

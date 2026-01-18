defmodule Samuser.Providers.ArtsDecoratifsTest do
  use ExUnit.Case, async: true
  alias Samuser.Providers.ArtsDecoratifs
  alias Samuser.Events.EventData

  describe "museum_info/0" do
    test "returns museum info" do
      info = ArtsDecoratifs.museum_info()
      assert info.name == "Musee des Arts Decoratifs"
      assert info.provider == :arts_decoratifs
    end
  end

  describe "to_event_data/1" do
    @tag :external
    test "parses HTML into event data" do
      {:ok, html} = ArtsDecoratifs.fetch_raw()
      assert {:ok, data} = ArtsDecoratifs.to_event_data(html)
      assert {:ok, _} = EventData.validate(data)
    end

    test "handles empty HTML" do
      assert {:ok, data} = ArtsDecoratifs.to_event_data("<html></html>")
      assert data["events"] == []
    end
  end
end

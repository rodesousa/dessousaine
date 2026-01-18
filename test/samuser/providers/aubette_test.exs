defmodule Samuser.Providers.AubetteTest do
  use ExUnit.Case, async: true
  alias Samuser.Providers.Aubette
  alias Samuser.Events.EventData

  describe "museum_info/0" do
    test "returns museum info" do
      info = Aubette.museum_info()
      assert info.name == "Aubette 1928"
      assert info.provider == :aubette
      assert String.starts_with?(info.url, "https://")
    end
  end

  describe "fetch_raw/0" do
    @tag :external
    test "fetches HTML from the museum page" do
      assert {:ok, html} = Aubette.fetch_raw()
      assert is_binary(html)
      assert String.contains?(html, "<!DOCTYPE") or String.contains?(html, "<html")
    end
  end

  describe "to_event_data/1" do
    @tag :external
    test "parses HTML into event data" do
      {:ok, html} = Aubette.fetch_raw()
      assert {:ok, data} = Aubette.to_event_data(html)

      assert is_map(data)
      assert is_list(data["events"])
      assert is_map(data["metadata"])
      assert data["metadata"]["museum_name"] == "Aubette 1928"
    end

    @tag :external
    test "validates against EventData schema" do
      {:ok, html} = Aubette.fetch_raw()
      {:ok, data} = Aubette.to_event_data(html)

      assert {:ok, _validated} = EventData.validate(data)
    end

    test "handles empty HTML gracefully" do
      assert {:ok, data} = Aubette.to_event_data("<html><body></body></html>")
      assert data["events"] == []
      assert data["metadata"]["total_events"] == 0
    end
  end

  describe "integration" do
    @tag :external
    test "full pipeline: fetch -> transform -> validate" do
      assert {:ok, html} = Aubette.fetch_raw()
      assert {:ok, data} = Aubette.to_event_data(html)
      assert {:ok, validated} = EventData.validate(data)

      assert is_list(validated["events"])
      assert is_map(validated["metadata"])

      if Enum.any?(validated["events"]) do
        event = hd(validated["events"])
        assert Map.has_key?(event, "title")
        assert event["title"] != nil
        assert event["title"] != ""
      end
    end
  end
end

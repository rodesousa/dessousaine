defmodule Dessousaine.CineDie.Providers.CosmosTest do
  use ExUnit.Case, async: true
  alias Dessousaine.CineDie.Providers.Cosmos
  alias Dessousaine.CineDie.Showtimes.ShowtimeData

  defp html(), do: Cosmos.fetch_raw() |> elem(1)

  describe "cinema_info/0" do
    test "cinema info" do
      info = Cosmos.cinema_info()
      assert info.name == "Le Cosmos"
      assert info.provider == :cosmos
      assert String.starts_with?(info.url, "https://")
    end
  end

  describe "to_showtime_data/1" do
    test "html parsing" do
      html = html()

      assert {:ok, data} = Cosmos.to_showtime_data(html)
      assert {:ok, _validated} = ShowtimeData.validate(data)
    end

    test "check fields" do
      html = html()

      {:ok, data} = Cosmos.to_showtime_data(html)
      film = hd(data["films"])

      # check title
      refute film["title"] in [nil, ""]

      refute film["link"] in [nil, ""]

      # check versions
      versions = Enum.map(film["sessions"], & &1["version"]) |> Enum.sort()
      assert Enum.any?(versions, &(&1 in ["VF", "VO"]))
    end
  end
end

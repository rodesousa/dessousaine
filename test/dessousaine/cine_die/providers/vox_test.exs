defmodule Dessousaine.CineDie.Providers.VoxTest do
  use ExUnit.Case, async: true
  alias Dessousaine.CineDie.Providers.Vox
  alias Dessousaine.CineDie.Showtimes.ShowtimeData

  defp html(), do: Vox.fetch_raw() |> elem(1)

  describe "cinema_info/0" do
    test "cinema info" do
      info = Vox.cinema_info()
      assert info.name == "Vox Strasbourg"
      assert info.provider == :vox
      assert String.starts_with?(info.url, "https://")
    end
  end

  describe "to_showtime_data/1" do
    test "html parsing" do
      html = html()

      assert {:ok, data} = Vox.to_showtime_data(html)
      assert {:ok, _validated} = ShowtimeData.validate(data)
    end

    test "check fields" do
      html = html()

      {:ok, data} = Vox.to_showtime_data(html)
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

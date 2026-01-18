defmodule DessousaineWeb.ErrorJSONTest do
  use DessousaineWeb.ConnCase, async: true

  test "renders 404" do
    assert DessousaineWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert DessousaineWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end

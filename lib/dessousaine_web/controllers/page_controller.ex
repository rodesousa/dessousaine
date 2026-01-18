defmodule DessousaineWeb.PageController do
  use DessousaineWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

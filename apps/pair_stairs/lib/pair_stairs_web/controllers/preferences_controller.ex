defmodule PairStairsWeb.PreferencesController do
  use PairStairsWeb, :controller

  def index(conn, _params) do
    conn
    |> render("index.html")
  end
end

defmodule PairStairsWeb.PreferencesController do
  use PairStairsWeb, :controller

  def index(conn, _params) do
    conn
    |> assign(:title, gettext("Preferences"))
    |> render("index.html")
  end
end

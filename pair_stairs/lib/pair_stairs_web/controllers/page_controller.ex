defmodule PairStairsWeb.PageController do
  use PairStairsWeb, :controller

  def index(conn, _params) do
    conn
    |> assign(:recent_stairs, recent_stairs_from(conn))
    |> render("index.html")
  end

  defp recent_stairs_from(conn) do
    conn
    |> get_session("recent_stairs") || []
  end
end

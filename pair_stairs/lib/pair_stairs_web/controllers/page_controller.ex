defmodule PairStairsWeb.PageController do
  use PairStairsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

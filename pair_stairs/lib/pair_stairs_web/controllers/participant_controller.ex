defmodule PairStairsWeb.ParticipantController do
  use PairStairsWeb, :controller

  def new(conn, _params) do
    conn
    |> render("new.html")
  end
end

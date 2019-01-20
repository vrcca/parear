defmodule PairStairsWeb.StairsController do
  use PairStairsWeb, :controller

  def new(conn, _params) do
    put_in(conn.params["new_stairs"], %{"limit" => "5"})
    |> render("new.html")
  end

  def create(conn, %{"new_stairs" => %{"name" => name, "limit" => limit}}) do
    with stairs_id <- Parear.new_stairs(name, limit: limit) do
      conn
      |> redirect(to: Routes.stairs_path(conn, :show, stairs_id))
    end
  end

  def show(conn, %{"id" => id}) do
    {:ok, stairs} =
      Parear.reload_by_id(id)
      |> Parear.list()

    render(conn, "show.html", stairs: stairs)
  end
end

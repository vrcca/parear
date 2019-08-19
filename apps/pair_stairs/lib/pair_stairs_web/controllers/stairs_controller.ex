defmodule PairStairsWeb.StairsController do
  use PairStairsWeb, :controller

  def new(conn, _params) do
    put_in(conn.params["new_stairs"], %{"limit" => "5"})
    |> render("new.html")
  end

  def create(conn, %{"new_stairs" => %{"name" => name, "limit" => limit}}) do
    with stairs_id <- Parear.new_stairs(name, limit: String.to_integer(limit)) do
      conn
      |> redirect(to: Routes.stairs_participant_path(conn, :index, stairs_id))
    end
  end

  def show(conn, %{"id" => id}) do
    {:ok, stairs} = Parear.list(id)

    conn
    |> save_to_recently_visited_stairs(stairs)
    |> assign(:title, stairs.name)
    |> render("show.html", stairs: stairs)
  end

  defp save_to_recently_visited_stairs(conn, stairs) do
    recent_stairs = conn |> get_session("recent_stairs") || []

    recent_stairs =
      Enum.filter(recent_stairs, fn s -> s.id != stairs.id end)
      |> Enum.slice(0, 5)

    stairs_infos = %{id: stairs.id, name: stairs.name}

    conn
    |> put_session("recent_stairs", [stairs_infos | recent_stairs])
  end
end

defmodule PairStairsWeb.StairsController do
  use PairStairsWeb, :controller

  alias Parear.Stairs

  def new(conn, _params) do
    put_in(conn.params["new_stairs"], %{"limit" => "5"})
    |> render("new.html")
  end

  def create(conn, %{"new_stairs" => %{"name" => name, "limit" => limit}}) do
    with stairs <- Parear.new_stairs(name, limit: limit),
         {:ok, %Stairs{id: stairs_id}} <- Parear.list(stairs),
         all_stairs <- conn |> get_session(:stairs) || %{} do
      conn
      |> put_session(:stairs, Map.put(all_stairs, stairs_id, stairs))
      |> redirect(to: Routes.stairs_path(conn, :show, stairs_id))
    end
  end

  def show(conn, %{"id" => id}) do
    all_stairs = conn |> get_session(:stairs) || %{}
    stairs = all_stairs |> Map.get_lazy(id, fn -> retrieve_from_database(id) end)

    conn
    |> put_session(:stairs, Map.put(all_stairs, id, stairs))

    render(conn, "index.html", stairs: stairs |> get_infos())
  end

  defp retrieve_from_database(id) do
    with {:ok, stairs} <- Parear.reload(id) do
      stairs |> IO.inspect()
    end
  end

  defp get_infos(stairs) do
    {:ok, infos} = Parear.list(stairs)
    infos
  end
end

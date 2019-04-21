defmodule PairStairsWeb.StatusController do
  use PairStairsWeb, :controller
  alias PairStairsWeb.{Endpoint, StairsView}

  def delete(conn, %{"stairs_id" => stairs_id}) do
    {:ok, _stairs} = Parear.reset_all_counters(stairs_id)
    {:ok, stairs} = Parear.list(stairs_id)

    Endpoint.broadcast("stairs:#{stairs_id}", "stairs", StairsView.convert_to_map(stairs))

    conn
    |> put_flash(:info, gettext("All status were ERASED!"))
    |> redirect(to: Routes.stairs_preferences_path(conn, :index, stairs_id))
  end
end

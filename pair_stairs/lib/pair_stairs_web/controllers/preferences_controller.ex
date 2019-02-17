defmodule PairStairsWeb.PreferencesController do
  use PairStairsWeb, :controller

  def index(conn, %{"stairs_id" => stairs_id}) do
    conn
    |> redirect(to: Routes.stairs_participant_path(conn, :index, stairs_id))
  end
end

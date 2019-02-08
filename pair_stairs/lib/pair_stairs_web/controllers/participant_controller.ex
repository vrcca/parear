defmodule PairStairsWeb.ParticipantController do
  use PairStairsWeb, :controller

  def index(conn, %{"stairs_id" => stairs_id}) do
    {:ok, stairs} = Parear.list(stairs_id)

    conn
    |> assign(:participants, stairs.participants)
    |> render("index.html")
  end

  def new(conn, _params) do
    conn
    |> render("new.html")
  end

  def delete(conn, %{"stairs_id" => stairs_id, "id" => participant_id}) do
    Parear.remove_participant_by_id(stairs_id, participant_id)

    conn
    |> put_flash(:info, gettext("Participant removed with success."))
    |> redirect(to: Routes.stairs_participant_path(conn, :index, stairs_id))
  end
end

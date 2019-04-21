defmodule PairStairsWeb.ParticipantController do
  use PairStairsWeb, :controller
  alias PairStairsWeb.{Endpoint, StairsView}

  def index(conn, %{"stairs_id" => stairs_id}) do
    {:ok, stairs} = Parear.list(stairs_id)

    conn
    |> assign(:participants, stairs.participants)
    |> assign(:title, gettext("Participants"))
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
    |> redirect_to_index(stairs_id)
  end

  def create(conn, %{"stairs_id" => stairs, "participant" => participant}) do
    stairs |> Parear.add_participant(participant["name"])

    conn
    |> put_flash(:info, gettext("Participant added with success!"))
    |> redirect_to_index(stairs)
  end

  defp redirect_to_index(conn, stairs_id) do
    {:ok, stairs} = Parear.list(stairs_id)
    Endpoint.broadcast("stairs:#{stairs_id}", "stairs", StairsView.convert_to_map(stairs))
    redirect(conn, to: Routes.stairs_participant_path(conn, :index, stairs_id))
  end
end

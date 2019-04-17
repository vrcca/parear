defmodule PairStairsWeb.StairsView do
  use PairStairsWeb, :view
  alias Parear.Stairs
  alias PairStairsWeb.ParticipantView

  def statuses_for(%Stairs{statuses: statuses}, id, friend_id) do
    get_in(statuses, [id, friend_id]) || 0
  end

  def manage_participants_button(conn, stairs_id) do
    link(gettext("Manage Participants"),
      to: Routes.stairs_participant_path(conn, :index, stairs_id),
      class: "button"
    )
  end

  def display_stairs_class(conn) do
    with %{"id" => id} <- conn.params,
         {:ok, stairs} <- Parear.list(id),
         true <- Enum.count(stairs.participants) >= 6 do
      "full-page-container"
    else
      _ -> ""
    end
  end

  def stairs_to_json(stairs = %Stairs{}) do
    stairs
    |> convert_to_map()
    |> Jason.encode!()
  end

  def convert_to_map(%Stairs{id: id, participants: participants, statuses: statuses}) do
    %{id: id, participants: convert_to_list(participants), statuses: statuses}
  end

  defp convert_to_list(participants = %{}) do
    ParticipantView.sorted_list(participants)
  end
end

defmodule PairStairsWeb.StairsView do
  use PairStairsWeb, :view
  alias Parear.Stairs

  def name_by_id(%Stairs{participants: participants}, id) do
    participants[id].name
  end

  def manage_participants_button(conn, stairs_id) do
    link(gettext("Manage Participants"),
      to: Routes.stairs_participant_path(conn, :index, stairs_id)
    )
  end
end

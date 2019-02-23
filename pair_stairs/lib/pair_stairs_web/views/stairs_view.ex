defmodule PairStairsWeb.StairsView do
  use PairStairsWeb, :view
  alias Parear.Stairs

  def statuses_for(%Stairs{statuses: statuses}, id, friend_id) do
    get_in(statuses, [id, friend_id]) || 0
  end

  def manage_participants_button(conn, stairs_id) do
    link(gettext("Manage Participants"),
      to: Routes.stairs_participant_path(conn, :index, stairs_id),
      class: "button"
    )
  end

  def display_stairs_class(_conn) do
    "full-page-container"
  end
end

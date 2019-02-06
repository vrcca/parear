defmodule PairStairsWeb.StairsView do
  use PairStairsWeb, :view
  alias Parear.Stairs

  def name_by_id(stairs = %Stairs{participants: participants}, id) do
    participants[id].name
  end

  def new_participant_button(conn, stairs_id) do
    link("Add New Participant", to: Routes.stairs_participant_path(conn, :new, stairs_id))
  end
end

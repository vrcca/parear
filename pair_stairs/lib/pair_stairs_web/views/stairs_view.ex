defmodule PairStairsWeb.StairsView do
  use PairStairsWeb, :view
  alias Parear.Stairs

  def name_by_id(stairs = %Stairs{participants: participants}, id) do
    participants[id].name
  end
end

defmodule PairStairsWeb.ParticipantView do
  use PairStairsWeb, :view

  def return_to_stairs_button(conn) do
    %{"stairs_id" => stairs_id} = conn.path_params
    link("Return to Stairs", to: Routes.stairs_path(conn, :show, stairs_id))
  end
end

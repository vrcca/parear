defmodule PairStairsWeb.PreferencesView do
  use PairStairsWeb, :view

  def manage_participants_button(conn) do
    %{"stairs_id" => stairs_id} = conn.path_params

    link(gettext("Manage participants"),
      to: Routes.stairs_participant_path(conn, :index, stairs_id)
    )
  end

  def return_to_stairs_button(conn) do
    %{"stairs_id" => stairs_id} = conn.path_params
    link(gettext("Return"), to: Routes.stairs_path(conn, :show, stairs_id))
  end
end

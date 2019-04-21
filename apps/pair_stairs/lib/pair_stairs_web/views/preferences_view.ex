defmodule PairStairsWeb.PreferencesView do
  use PairStairsWeb, :view

  def return_to_stairs_button(conn) do
    %{"stairs_id" => stairs_id} = conn.path_params
    link(gettext("Return"), to: Routes.stairs_path(conn, :show, stairs_id))
  end

  def manage_participants_button(conn) do
    %{"stairs_id" => stairs_id} = conn.path_params

    link(gettext("Manage participants"),
      to: Routes.stairs_participant_path(conn, :index, stairs_id)
    )
  end

  def reset_stairs_button(conn) do
    %{"stairs_id" => stairs_id} = conn.path_params

    link("Reset stairs counter",
      to: Routes.stairs_status_path(conn, :delete, stairs_id),
      method: :delete,
      data: [confirm: gettext("This action will REMOVE any previous pair counts. Are you sure?")],
      class: 'link-danger'
    )
  end
end

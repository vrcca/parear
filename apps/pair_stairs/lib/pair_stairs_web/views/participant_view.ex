defmodule PairStairsWeb.ParticipantView do
  use PairStairsWeb, :view

  def return_to_stairs_button(conn) do
    %{"stairs_id" => stairs_id} = conn.path_params
    link(gettext("Return"), to: Routes.stairs_path(conn, :show, stairs_id))
  end

  def remove_participant_button(conn, participant_id) do
    %{"stairs_id" => stairs_id} = conn.path_params

    link("Remove",
      to: Routes.stairs_participant_path(conn, :delete, stairs_id, participant_id),
      method: :delete,
      data: [confirm: gettext("This action will remove any previous pair counts. Are you sure?")]
    )
  end

  def sorted_list(participants = %{}) do
    Enum.reduce(participants, [], fn {_id, p}, acc ->
      [Map.from_struct(p) | acc]
    end)
    |> Enum.sort(&(&1.name <= &2.name))
  end
end

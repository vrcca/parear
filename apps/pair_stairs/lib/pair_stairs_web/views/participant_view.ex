defmodule PairStairsWeb.ParticipantView do
  use PairStairsWeb, :view
  import PairStairsWeb.PreferencesView, only: [return_to_stairs_button: 1]

  def return_to_preferences_button(conn) do
    %{"stairs_id" => stairs_id} = conn.path_params
    link(gettext("Preferences"), to: Routes.stairs_preferences_path(conn, :index, stairs_id))
  end

  def remove_participant_button(conn, participant_id) do
    %{"stairs_id" => stairs_id} = conn.path_params

    link("🗑",
      title: gettext("Remove"),
      to: Routes.stairs_participant_path(conn, :delete, stairs_id, participant_id),
      method: :delete,
      data: [confirm: gettext("This action will remove any previous pair counts. Are you sure?")]
    )
  end

  def edit_participant_button(conn, participant_id) do
    %{"stairs_id" => stairs_id} = conn.path_params

    link("✏️", title: gettext("Edit"), to: "#edit=#{participant_id}")
  end

  def sorted_list(participants = %{}) do
    Enum.reduce(participants, [], fn {_id, p}, acc ->
      [Map.from_struct(p) | acc]
    end)
    |> Enum.sort(&(&1.name <= &2.name))
  end
end

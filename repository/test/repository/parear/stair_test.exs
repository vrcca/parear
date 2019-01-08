defmodule Repository.Parear.StairTest do
  alias Repository.Parear.{Stair, Participant, Repo}
  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    %{pair_stairs: Parear.Stairs.new("Whiskey", limit: 10)}
  end

  test "Inserts stair with same id from Parear.Stairs", %{pair_stairs: stairs} do
    {:ok, inserted_stairs} = Stair.save_cascade(stairs)
    assert stairs.id == Map.get(inserted_stairs, :id)
  end

  test "Updates stair with new name", %{pair_stairs: stairs} do
    {:ok, _} = Stair.save_cascade(stairs)

    stairs_with_new_name = %{stairs | name: "New Whiskey"}
    {:ok, _} = Stair.save_cascade(stairs_with_new_name)

    stairs = Stair.find_by_id(stairs.id)
    assert "New Whiskey" == stairs.name
  end

  test "Saves name and limit from Parear.Stairs", %{pair_stairs: stairs} do
    assert [] == Repository.Parear.Repo.all(Stair)

    {:ok, _stairs} = Stair.save_cascade(stairs)

    saved_stair = Stair.find_by_id(stairs.id)
    assert stairs.name == saved_stair.name
    assert stairs.limit == saved_stair.limit
  end

  test "Saves participants from Parear.Stairs", %{pair_stairs: stairs} do
    updated_stairs = Parear.Stairs.add_participant(stairs, "Vitor")

    {:ok, created_stairs} = Stair.save_cascade(updated_stairs)
    stair_with_participants = Stair.load_participants(created_stairs)

    assert [] != stair_with_participants.participants
    [first | _] = stair_with_participants.participants
    assert nil != first.id
    assert "Vitor" == first.name
  end

  test "Deletes removed participant from stair", %{pair_stairs: stairs} do
    updated_stairs =
      stairs
      |> Parear.Stairs.add_participant("Vitor")
      |> Parear.Stairs.add_participant("Kenya")

    {:ok, _} = Stair.save_cascade(updated_stairs)

    {:ok, saved_stairs} =
      updated_stairs
      |> Parear.Stairs.remove_participant("Vitor")
      |> Stair.save_cascade()

    stair_with_participants = Stair.load_participants(saved_stairs)
    assert stair_with_participants |> has_participant_named?("Kenya")
    assert false == stair_with_participants |> has_participant_named?("Vitor")
  end

  @tag :pending
  test "Saves pair status from Parear.Stairs", %{pair_stairs: stairs} do
    id = stairs.id

    {:ok, stairs_with_status} =
      stairs
      |> Parear.Stairs.add_participant("Vitor")
      |> Parear.Stairs.add_participant("Kenya")
      |> Parear.Stairs.pair("Vitor", "Kenya")

    {:ok, _} = Stair.save_cascade(stairs_with_status)

    pair_statuses =
      Stair.find_by_id(id)
      |> Stair.load_pair_statuses()
      |> Map.get(:pair_statuses)

    assert false == Enum.empty?(pair_statuses)
  end

  defp has_participant_named?(stair = %Stair{}, name) do
    Map.get(stair, :participants)
    |> has_participant_named?(name)
  end

  defp has_participant_named?(participants, name) do
    Enum.any?(participants, fn p ->
      get_name(p) == name
    end)
  end

  defp get_name(p = %Participant{}), do: Map.get(p, :name)
  defp get_name(p), do: Ecto.Changeset.get_field(p, :name)
end

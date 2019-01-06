defmodule Repository.Parear.StairTest do
  alias Repository.Parear.{Stair, Repo}
  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    %{pair_stairs: Parear.Stairs.new("Whiskey", limit: 10)}
  end

  test "Inserts stair with same id from Parear.Stairs", %{pair_stairs: stairs} do
    {:ok, inserted_stairs} = Stair.save_all_from(stairs)
    assert stairs.id == Map.get(inserted_stairs, :id)
  end

  test "Updates stair with new name", %{pair_stairs: stairs} do
    {:ok, _} = Stair.save_all_from(stairs)

    stairs_with_new_name = %{stairs | name: "New Whiskey"}
    {:ok, _} = Stair.save_all_from(stairs_with_new_name)

    stairs = Stair.find_by_id(stairs.id)
    assert "New Whiskey" == stairs.name
  end

  test "Saves name and limit from Parear.Stairs", %{pair_stairs: stairs} do
    assert [] == Repository.Parear.Repo.all(Stair)

    {:ok, _stairs} = Stair.save_all_from(stairs)

    saved_stair = Stair.find_by_id(stairs.id)
    assert stairs.name == saved_stair.name
    assert stairs.limit == saved_stair.limit
  end

  test "Saves participants from Parear.Stairs", %{pair_stairs: stairs} do
    updated_stairs = Parear.Stairs.add_participant(stairs, "Vitor")

    {:ok, created_stairs} = Stair.save_all_from(updated_stairs)
    stair_with_participants = Stair.load_participants(created_stairs)

    assert [] != stair_with_participants.participants
    [first | _] = stair_with_participants.participants
    assert nil != first.id
    assert "Vitor" == first.name
  end

  @tag :pending
  test "Saves pair status from Parear.Stairs" do
  end
end

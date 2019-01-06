defmodule Repository.Parear.StairTest do
  alias Repository.Parear.{Stair, Repo}
  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "Saves name and limit from Parear.Stairs" do
    assert [] == Stair.all()

    {:ok, _stairs} = Stair.save_all_from(Parear.Stairs.new("Whiskey", limit: 10))

    [first | _rest] = Stair.all()
    assert "Whiskey" == first.name
    assert 10 == first.limit
  end

  test "Saves participants from Parear.Stairs" do
    updated_stairs =
      with pair_stairs <- Parear.Stairs.new("Whiskey with participants", limit: 10) do
        Parear.Stairs.add_participant(pair_stairs, "Vitor")
      end

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

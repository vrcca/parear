defmodule Repository.Parear.PairStatusTest do
  alias Repository.Parear.{Stair, PairStatus, Repo}
  alias Parear.Stairs
  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    %{pair_stairs: Parear.Stairs.new("Whiskey", limit: 10)}
  end

  test "Returns empty when there are no participants", %{pair_stairs: stairs} do
    pair_statuses = PairStatus.convert_all_from(stairs)
    assert Enum.empty?(pair_statuses)
  end

  @tag :pending
  test "Returns matching pairs with participants with zeroes", %{pair_stairs: stairs} do
    stairs =
      Stairs.add_participant("Vitor")
      |> Stairs.add_participant("Kenya")

    pair_statuses = PairStatus.convert_all_from(stairs)
    assert false == Enum.empty?(pair_statuses)
  end
end

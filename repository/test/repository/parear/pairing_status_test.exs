defmodule Repository.Parear.PairStatusTest do
  alias Repository.Parear.{Stair, Repo}
  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    %{pair_stairs: Parear.Stairs.new("Whiskey", limit: 10)}
  end

  @tag :pending
  test "Converts participants from Parear.Stairs", %{pair_stairs: stairs} do
  end
end

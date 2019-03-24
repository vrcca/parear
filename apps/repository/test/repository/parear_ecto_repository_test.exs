defmodule Repository.ParearEctoRepositoryTest do
  alias Repository.Parear.Repo
  use ExUnit.Case, async: true

  @repository Repository.ParearEctoRepository

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    %{pair_stairs: Parear.Stairs.new("New Whiskey", limit: 10)}
  end

  test "Should return ok and domain stairs when found by id", %{pair_stairs: stairs} do
    @repository.save(stairs)
    id = stairs.id
    assert {:ok, stairs} == @repository.find_by_id(id)
  end

  test "Should return :none when not found by id" do
    unknown_id = "83c658ac-6091-4304-bc5a-989e215d22a8"
    assert {:none} == @repository.find_by_id(unknown_id)
  end

  test "Should convert back participants and statuses to domain", %{pair_stairs: stairs} do
    stairs_with_participant =
      stairs
      |> Parear.Stairs.add_participant("Vitor")
      |> Parear.Stairs.add_participant("Elvis")
      |> Parear.Stairs.add_participant("Kenya")

    @repository.save(stairs_with_participant)

    assert {:ok, stairs_with_participant} == @repository.find_by_id(stairs.id)
  end
end

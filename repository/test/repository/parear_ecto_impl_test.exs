defmodule Repository.ParearEctoImplTest do
  alias Repository.Parear.Repo
  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    %{pair_stairs: Parear.Stairs.new("New Whiskey", limit: 10)}
  end

  test "Should return ok and domain stairs when found by id", %{pair_stairs: stairs} do
    Parear.Repository.save(stairs)
    id = stairs.id
    assert {:ok, stairs} == Parear.Repository.find_by_id(%Parear.Stairs{id: id})
  end

  test "Should return :none when not found by id" do
    unknown_id = "83c658ac-6091-4304-bc5a-989e215d22a8"
    assert {:none} == Parear.Repository.find_by_id(%Parear.Stairs{id: unknown_id})
  end

  test "Should return ok and domain stairs when found by name", %{pair_stairs: stairs} do
    Parear.Repository.save(stairs)
    name = stairs.name
    assert {:ok, stairs} == Parear.Repository.find_by_name(%Parear.Stairs{name: name})
  end

  test "Should return :none when not found by name" do
    unknown_name = "Huehue"
    assert {:none} == Parear.Repository.find_by_name(%Parear.Stairs{name: unknown_name})
  end

  test "Should convert back participants and statuses to domain", %{pair_stairs: stairs} do
    stairs_with_participant =
      stairs
      |> Parear.Stairs.add_participant("Vitor")
      |> Parear.Stairs.add_participant("Elvis")
      |> Parear.Stairs.add_participant("Kenya")

    Parear.Repository.save(stairs_with_participant)

    assert {:ok, stairs_with_participant} == Parear.Repository.find_by_id(stairs)
  end
end

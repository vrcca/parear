defmodule ParearTest do
  use ExUnit.Case, async: true
  doctest Parear
  alias Parear.Stairs
  alias Parear.Repository

  setup do
    start_supervised!(Parear.Support.MemoryRepository)
    stairs_pid = Parear.new_stairs("Whiskey", limit: 10)
    {:ok, %Stairs{id: id}} = Parear.list(stairs_pid)
    %{stairs_pid: stairs_pid, stairs_id: id}
  end

  test "Creates stairs", %{stairs_id: stairs_id} do
    {:ok, stairs} = Parear.list(stairs_id)
    assert stairs.name == "Whiskey"
    assert stairs.limit == 10
    assert Enum.empty?(stairs.participants)
    assert not (stairs.id == "")
  end

  test "Adds participants", %{stairs_id: stairs_id} do
    Parear.add_participant(stairs_id, "Kenya")
    {:ok, %{stairs: stairs}} = Parear.add_participant(stairs_id, "Vitor")
    assert true == Enum.any?(stairs, fn {participant, _} -> participant.name == "Vitor" end)
    assert true == Enum.any?(stairs, fn {participant, _} -> participant.name == "Kenya" end)
  end

  test "Reloads from repository by id" do
    new_stairs =
      Stairs.new("The new stairs")
      |> Repository.save()

    Parear.reload_by_id(new_stairs.id)
    {:ok, reloaded_stairs} = Parear.list(new_stairs.id)

    assert reloaded_stairs == new_stairs
  end

  test "Returns same stairs process if it already has one", %{
    stairs_pid: stairs_pid,
    stairs_id: stairs_id
  } do
    {:ok, stairs} = Parear.list(stairs_id)
    reloaded_stairs_pid = Parear.reload_by_id(stairs.id)
    assert reloaded_stairs_pid == stairs_pid
  end

  test "Reloads from repository by name" do
    new_stairs =
      Stairs.new("The new stairs")
      |> Repository.save()

    Parear.reload_by_name(new_stairs.name)
    {:ok, reloaded_stairs} = Parear.list(new_stairs.id)

    assert reloaded_stairs == new_stairs
  end

  test "Reloading from repository by name returns same process", %{
    stairs_pid: stairs_pid,
    stairs_id: stairs_id
  } do
    {:ok, stairs} = Parear.list(stairs_id)
    reloaded_stairs_pid = Parear.reload_by_name(stairs.name)
    assert reloaded_stairs_pid == stairs_pid
  end

  test "Fails to start when reloading an unknown stair by id" do
    {:error, reason} = Parear.reload_by_id("unknown-id")
    assert reason == :stairs_could_not_be_found
  end

  test "Fails to start when reloading an unknown stair by name" do
    {:error, reason} = Parear.reload_by_name("unknown-name")
    assert reason == :stairs_could_not_be_found
  end

  test "Persists new participants to repository by id", %{stairs_id: id} do
    Parear.add_participant(id, "Vitor")
    {:ok, stairs} = Parear.list(id)

    Parear.reload_by_id(id)
    {:ok, reloaded_stairs} = Parear.list(id)

    assert stairs == reloaded_stairs
  end

  test "Persists removed participants to repository", %{
    stairs_pid: stairs_pid,
    stairs_id: stairs_id
  } do
    Parear.add_participant(stairs_id, "Vitor")
    Parear.remove_participant(stairs_pid, "Vitor")
    {:ok, stairs} = Parear.list(stairs_id)

    Parear.reload_by_id(stairs.id)
    {:ok, reloaded_stairs} = Parear.list(stairs_id)

    assert stairs == reloaded_stairs
  end

  test "Persists new pairings to repository", %{stairs_pid: stairs_pid, stairs_id: stairs_id} do
    Parear.add_participant(stairs_id, "Vitor")
    Parear.add_participant(stairs_id, "Kenya")
    Parear.pair(stairs_pid, "Vitor", "Kenya")
    {:ok, stairs} = Parear.list(stairs_id)

    Parear.reload_by_id(stairs.id)
    {:ok, reloaded_stairs} = Parear.list(stairs_id)

    assert stairs == reloaded_stairs
  end

  test "Persists undone pairings to repository", %{stairs_pid: stairs_pid, stairs_id: stairs_id} do
    Parear.add_participant(stairs_id, "Vitor")
    Parear.add_participant(stairs_id, "Kenya")
    Parear.pair(stairs_pid, "Vitor", "Kenya")
    Parear.unpair(stairs_pid, "Vitor", "Kenya")
    {:ok, stairs} = Parear.list(stairs_pid)

    {:ok, reloaded_stairs} =
      Parear.reload_by_id(stairs.id)
      |> Parear.list()

    assert stairs == reloaded_stairs
  end

  test "Persists reseted counters to repository", %{stairs_pid: stairs_pid, stairs_id: stairs_id} do
    Parear.add_participant(stairs_id, "Vitor")
    Parear.add_participant(stairs_id, "Kenya")
    Parear.pair(stairs_pid, "Vitor", "Kenya")
    Parear.reset_all_counters(stairs_pid)
    {:ok, stairs} = Parear.list(stairs_pid)

    Parear.reload_by_id(stairs_id)
    {:ok, reloaded_stairs} = Parear.list(stairs_id)

    assert stairs == reloaded_stairs
  end
end

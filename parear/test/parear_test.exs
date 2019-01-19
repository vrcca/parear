defmodule ParearTest do
  use ExUnit.Case, async: true
  doctest Parear
  alias Parear.Stairs
  alias Parear.Repository

  setup do
    start_supervised!(Parear.Support.MemoryRepository)
    stairs_pid = Parear.new_stairs("Whiskey", limit: 10)
    %{stairs_pid: stairs_pid}
  end

  test "Creates stairs", %{stairs_pid: stairs_pid} do
    {:ok, stairs} = Parear.list(stairs_pid)
    assert stairs.name == "Whiskey"
    assert stairs.limit == 10
    assert Enum.empty?(stairs.participants)
    assert not (stairs.id == "")
  end

  test "Adds participants", %{stairs_pid: stairs_pid} do
    Parear.add_participant(stairs_pid, "Kenya")
    {:ok, %{stairs: stairs}} = Parear.add_participant(stairs_pid, "Vitor")
    assert true == Enum.any?(stairs, fn {participant, _} -> participant.name == "Vitor" end)
    assert true == Enum.any?(stairs, fn {participant, _} -> participant.name == "Kenya" end)
  end

  test "Reloads from repository by id" do
    new_stairs =
      Stairs.new("The new stairs")
      |> Repository.save()

    {:ok, reloaded_stairs} =
      Parear.reload_by_id(new_stairs.id)
      |> Parear.list()

    assert reloaded_stairs == new_stairs
  end

  test "Returns same stairs process if it already has one", %{stairs_pid: stairs_pid} do
    {:ok, stairs} = Parear.list(stairs_pid)
    reloaded_stairs_pid = Parear.reload_by_id(stairs.id)
    assert reloaded_stairs_pid == stairs_pid
  end

  test "Reloads from repository by name" do
    new_stairs =
      Stairs.new("The new stairs")
      |> Repository.save()

    {:ok, reloaded_stairs} =
      Parear.reload_by_name(new_stairs.name)
      |> Parear.list()

    assert reloaded_stairs == new_stairs
  end

  test "Reloading from repository by name returns same process", %{stairs_pid: stairs_pid} do
    {:ok, stairs} = Parear.list(stairs_pid)
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

  test "Persists new participants to repository", %{stairs_pid: stairs_pid} do
    Parear.add_participant(stairs_pid, "Vitor")
    {:ok, stairs} = Parear.list(stairs_pid)

    {:ok, reloaded_stairs} =
      Parear.reload_by_id(stairs.id)
      |> Parear.list()

    assert stairs == reloaded_stairs
  end

  test "Persists removed participants to repository", %{stairs_pid: stairs_pid} do
    Parear.add_participant(stairs_pid, "Vitor")
    Parear.remove_participant(stairs_pid, "Vitor")
    {:ok, stairs} = Parear.list(stairs_pid)

    {:ok, reloaded_stairs} =
      Parear.reload_by_id(stairs.id)
      |> Parear.list()

    assert stairs == reloaded_stairs
  end

  test "Persists new pairings to repository", %{stairs_pid: stairs_pid} do
    Parear.add_participant(stairs_pid, "Vitor")
    Parear.add_participant(stairs_pid, "Kenya")
    Parear.pair(stairs_pid, "Vitor", "Kenya")
    {:ok, stairs} = Parear.list(stairs_pid)

    {:ok, reloaded_stairs} =
      Parear.reload_by_id(stairs.id)
      |> Parear.list()

    assert stairs == reloaded_stairs
  end

  test "Persists undone pairings to repository", %{stairs_pid: stairs_pid} do
    Parear.add_participant(stairs_pid, "Vitor")
    Parear.add_participant(stairs_pid, "Kenya")
    Parear.pair(stairs_pid, "Vitor", "Kenya")
    Parear.unpair(stairs_pid, "Vitor", "Kenya")
    {:ok, stairs} = Parear.list(stairs_pid)

    {:ok, reloaded_stairs} =
      Parear.reload_by_id(stairs.id)
      |> Parear.list()

    assert stairs == reloaded_stairs
  end

  test "Persists reseted counters to repository", %{stairs_pid: stairs_pid} do
    Parear.add_participant(stairs_pid, "Vitor")
    Parear.add_participant(stairs_pid, "Kenya")
    Parear.pair(stairs_pid, "Vitor", "Kenya")
    Parear.reset_all_counters(stairs_pid)
    {:ok, stairs} = Parear.list(stairs_pid)

    {:ok, reloaded_stairs} =
      Parear.reload_by_id(stairs.id)
      |> Parear.list()

    assert stairs == reloaded_stairs
  end
end

defmodule ParearTest do
  use ExUnit.Case, async: true
  doctest Parear

  setup do
    start_supervised!(Parear.Support.MemoryRepository)
    stairs = start_supervised!({Parear.Server, %{name: "Whiskey", options: [limit: 10]}})
    %{stairs: stairs}
  end

  test "Creates stairs", %{stairs: stairs} do
    {:ok, stairs} = Parear.list(stairs)
    assert stairs.name == "Whiskey"
    assert stairs.limit == 10
    assert Enum.empty?(stairs.participants)
    assert not (stairs.id == "")
  end

  test "Adds participants", %{stairs: stairs} do
    Parear.add_participant(stairs, "Kenya")
    {:ok, %{stairs: stairs}} = Parear.add_participant(stairs, "Vitor")
    assert true == Enum.any?(stairs, fn {participant, _} -> participant.name == "Vitor" end)
    assert true == Enum.any?(stairs, fn {participant, _} -> participant.name == "Kenya" end)
  end

  test "Reloads from repository by id", %{stairs: stairs} do
    {:ok, stairs} = Parear.list(stairs)

    {:ok, reloaded_stairs} =
      Parear.reload(stairs.id)
      |> Parear.list()

    assert stairs == reloaded_stairs
  end

  test "Fails to start when reloading an unknown stair by id" do
    {:error, %{reason: reason, args: args}} = Parear.reload("unknown-id")
    assert reason == :stairs_could_not_be_found
    assert args == %{id: "unknown-id"}
  end

  test "Fails to start when reloading an unknown stair by name" do
    {:error, %{reason: reason, args: args}} = Parear.reload_by_name("unknown-name")
    assert reason == :stairs_could_not_be_found
    assert args == %{name: "unknown-name"}
  end

  test "Reloads from repository by name", %{stairs: stairs} do
    {:ok, stairs} = Parear.list(stairs)

    {:ok, reloaded_stairs} =
      Parear.reload_by_name(stairs.name)
      |> Parear.list()

    assert stairs == reloaded_stairs
  end

  test "Persists new participants to repository", %{stairs: stairs} do
    Parear.add_participant(stairs, "Vitor")
    {:ok, stairs} = Parear.list(stairs)

    {:ok, reloaded_stairs} =
      Parear.reload(stairs.id)
      |> Parear.list()

    assert stairs == reloaded_stairs
  end

  test "Persists removed participants to repository", %{stairs: stairs} do
    Parear.add_participant(stairs, "Vitor")
    Parear.remove_participant(stairs, "Vitor")
    {:ok, stairs} = Parear.list(stairs)

    {:ok, reloaded_stairs} =
      Parear.reload(stairs.id)
      |> Parear.list()

    assert stairs == reloaded_stairs
  end

  test "Persists new pairings to repository", %{stairs: stairs} do
    Parear.add_participant(stairs, "Vitor")
    Parear.add_participant(stairs, "Kenya")
    Parear.pair(stairs, "Vitor", "Kenya")
    {:ok, stairs} = Parear.list(stairs)

    {:ok, reloaded_stairs} =
      Parear.reload(stairs.id)
      |> Parear.list()

    assert stairs == reloaded_stairs
  end

  test "Persists undone pairings to repository", %{stairs: stairs} do
    Parear.add_participant(stairs, "Vitor")
    Parear.add_participant(stairs, "Kenya")
    Parear.pair(stairs, "Vitor", "Kenya")
    Parear.unpair(stairs, "Vitor", "Kenya")
    {:ok, stairs} = Parear.list(stairs)

    {:ok, reloaded_stairs} =
      Parear.reload(stairs.id)
      |> Parear.list()

    assert stairs == reloaded_stairs
  end

  test "Persists reseted counters to repository", %{stairs: stairs} do
    Parear.add_participant(stairs, "Vitor")
    Parear.add_participant(stairs, "Kenya")
    Parear.pair(stairs, "Vitor", "Kenya")
    Parear.reset_all_counters(stairs)
    {:ok, stairs} = Parear.list(stairs)

    {:ok, reloaded_stairs} =
      Parear.reload(stairs.id)
      |> Parear.list()

    assert stairs == reloaded_stairs
  end
end

defmodule Parear.ServerTest do
  use ExUnit.Case, async: true

  setup do
    start_supervised!(Parear.Support.MemoryRepository)
    server = start_supervised!({Parear.Server, %{name: "Whiskey", options: [limit: 10]}})
    %{server: server}
  end

  test "Creates stairs", %{server: server} do
    {:ok, stairs} = Parear.list(server)
    assert stairs.name == "Whiskey"
    assert stairs.limit == 10
    assert Enum.empty?(stairs.participants)
    assert not (stairs.id == "")
  end

  test "Adds participants", %{server: server} do
    Parear.add_participant(server, "Kenya")
    {:ok, %{stairs: stairs}} = Parear.add_participant(server, "Vitor")
    assert true == Enum.any?(stairs, fn {participant, _} -> participant.name == "Vitor" end)
    assert true == Enum.any?(stairs, fn {participant, _} -> participant.name == "Kenya" end)
  end

  test "Reloads from repository by id", %{server: server} do
    {:ok, stairs} = Parear.list(server)

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

  test "Reloads from repository by name", %{server: server} do
    {:ok, stairs} = Parear.list(server)

    {:ok, reloaded_stairs} =
      Parear.reload_by_name(stairs.name)
      |> Parear.list()

    assert stairs == reloaded_stairs
  end

  test "Persists new participants to repository", %{server: server} do
    Parear.add_participant(server, "Vitor")
    {:ok, stairs} = Parear.list(server)

    {:ok, reloaded_stairs} =
      Parear.reload(stairs.id)
      |> Parear.list()

    assert stairs == reloaded_stairs
  end

  test "Persists removed participants to repository", %{server: server} do
    Parear.add_participant(server, "Vitor")
    Parear.remove_participant(server, "Vitor")
    {:ok, stairs} = Parear.list(server)

    {:ok, reloaded_stairs} =
      Parear.reload(stairs.id)
      |> Parear.list()

    assert stairs == reloaded_stairs
  end

  test "Persists new pairings to repository", %{server: server} do
    Parear.add_participant(server, "Vitor")
    Parear.add_participant(server, "Kenya")
    Parear.pair(server, "Vitor", "Kenya")
    {:ok, stairs} = Parear.list(server)

    {:ok, reloaded_stairs} =
      Parear.reload(stairs.id)
      |> Parear.list()

    assert stairs == reloaded_stairs
  end

  test "Persists undone pairings to repository", %{server: server} do
    Parear.add_participant(server, "Vitor")
    Parear.add_participant(server, "Kenya")
    Parear.pair(server, "Vitor", "Kenya")
    Parear.unpair(server, "Vitor", "Kenya")
    {:ok, stairs} = Parear.list(server)

    {:ok, reloaded_stairs} =
      Parear.reload(stairs.id)
      |> Parear.list()

    assert stairs == reloaded_stairs
  end

  test "Persists reseted counters to repository", %{server: server} do
    Parear.add_participant(server, "Vitor")
    Parear.add_participant(server, "Kenya")
    Parear.pair(server, "Vitor", "Kenya")
    Parear.reset_all_counters(server)
    {:ok, stairs} = Parear.list(server)

    {:ok, reloaded_stairs} =
      Parear.reload(stairs.id)
      |> Parear.list()

    assert stairs == reloaded_stairs
  end
end

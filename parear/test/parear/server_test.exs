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
    assert Enum.empty?(stairs.all_participants)
    assert not (stairs.id == "")
  end

  test "Adds participants", %{server: server} do
    {:ok, %{stairs: stairs}} = Parear.add_participant(server, "Vitor")
    assert true == Enum.any?(stairs, fn {participant, _} -> participant.name == "Vitor" end)
  end

  test "Reloads from repository", %{server: server} do
    {:ok, stairs} = Parear.list(server)

    {:ok, reloaded_stairs} =
      Parear.reload(stairs.id)
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

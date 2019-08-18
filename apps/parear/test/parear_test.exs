defmodule ParearTest do
  use ExUnit.Case, async: false
  doctest Parear
  alias Parear.{Stairs, Participant}
  import Mox

  setup :verify_on_exit!
  setup :set_mox_global

  setup do
    new_stairs = Stairs.new("The default stairs")
    stairs_id = new_stairs.id

    Parear.MockRepository
    |> stub(:find_by_id, fn ^stairs_id -> {:ok, new_stairs} end)

    Parear.MockRepository
    |> stub(:save, fn stairs -> {:ok, stairs} end)

    Parear.ParticipantMockRepository
    |> stub(:insert, fn participant, ^stairs_id -> {:ok, participant} end)

    %{stairs_id: stairs_id}
  end

  test "Creates stairs" do
    Parear.MockRepository
    |> expect(:save, fn stairs -> stairs end)

    {:ok, stairs} =
      Parear.new_stairs("Whiskey", limit: 10)
      |> Parear.list()

    assert stairs.name == "Whiskey"
    assert stairs.limit == 10
    assert Enum.empty?(stairs.participants)
    assert not (stairs.id == "")
  end

  test "Restarts stairs from repository by id" do
    new_stairs = Stairs.new("The new stairs")
    id = new_stairs.id

    Parear.MockRepository
    |> expect(:find_by_id, fn ^id -> {:ok, new_stairs} end)

    {:ok, reloaded_stairs} = Parear.list(new_stairs.id)

    assert reloaded_stairs == new_stairs
  end

  test "Fails to start when listing an unknown stair by id" do
    Parear.MockRepository
    |> expect(:find_by_id, fn _id -> {:none} end)

    unknown_id = "31b755c8-701d-4406-9eba-9a4fbbb6fec2"
    {:error, reason} = Parear.list(unknown_id)

    assert reason == :stairs_could_not_be_found
  end

  test "Adds participants", %{stairs_id: stairs_id} do
    Parear.ParticipantMockRepository
    |> expect(:insert, fn p = %Participant{name: "Kenya"}, ^stairs_id -> {:ok, p} end)

    Parear.ParticipantMockRepository
    |> expect(:insert, fn p = %Participant{name: "Vitor"}, ^stairs_id -> {:ok, p} end)

    Parear.add_participant(stairs_id, "Kenya")
    {:ok, %{stairs: stairs}} = Parear.add_participant(stairs_id, "Vitor")
    assert true == Enum.any?(stairs, fn {participant, _} -> participant.name == "Vitor" end)
    assert true == Enum.any?(stairs, fn {participant, _} -> participant.name == "Kenya" end)
  end

  @tag :pending
  test "Persists new pairings to repository", %{stairs_id: stairs_id} do
    Parear.add_participant(stairs_id, "Vitor")
    Parear.add_participant(stairs_id, "Kenya")
    Parear.pair(stairs_id, "Vitor", "Kenya")
    {:ok, stairs} = Parear.list(stairs_id)
    kill_process_by_stairs_id(stairs_id)
    {:ok, reloaded_stairs} = Parear.list(stairs_id)
    assert stairs == reloaded_stairs
  end

  @tag :pending
  test "Persists undone pairings to repository", %{stairs_id: stairs_id} do
    Parear.add_participant(stairs_id, "Vitor")
    Parear.add_participant(stairs_id, "Kenya")
    Parear.pair(stairs_id, "Vitor", "Kenya")
    Parear.unpair(stairs_id, "Vitor", "Kenya")
    {:ok, stairs} = Parear.list(stairs_id)

    {:ok, reloaded_stairs} =
      Parear.reload_by_id(stairs.id)
      |> Parear.list()

    assert stairs == reloaded_stairs
  end

  @tag :pending
  test "Persists reseted counters to repository", %{stairs_id: stairs_id} do
    Parear.add_participant(stairs_id, "Vitor")
    Parear.add_participant(stairs_id, "Kenya")
    Parear.pair(stairs_id, "Vitor", "Kenya")
    Parear.reset_all_counters(stairs_id)
    {:ok, stairs} = Parear.list(stairs_id)

    Parear.reload_by_id(stairs_id)
    {:ok, reloaded_stairs} = Parear.list(stairs_id)

    assert stairs == reloaded_stairs
  end

  defp kill_process_by_stairs_id(id) do
    Registry.lookup(Registry.Stairs, id)
    |> case do
      [] -> :no_process_killed
      [{pid, _}] -> Process.exit(pid, :kill)
    end
  end
end

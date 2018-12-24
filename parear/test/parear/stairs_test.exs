defmodule Parear.StairsTest do
  use ExUnit.Case
  doctest Parear.Stairs
  alias Parear.Stairs

  test "Creates a new stairs with id and name" do
    stairs = Stairs.new("Whiskey")
    assert stairs.name == "Whiskey"
    assert stairs.id != nil
  end

  test "Adds participant with no matching pair" do
    stairs =
      Stairs.new("Another")
      |> Stairs.add_participant("Vitor")

    assert Enum.empty?(stairs.participants) == false
    assert Map.get(stairs.participants, "Vitor") == %{}
  end

  test "Adding a second participant automatically matches with everybody else" do
    stairs = stairs_with_two_participants()
    assert Enum.count(stairs.participants) == 2
    assert Map.get(stairs.participants, "Vitor") == %{"Kenya" => 0}
    assert Map.get(stairs.participants, "Kenya") == %{"Vitor" => 0}
  end

  test "Pairing two participants automatically updates their pair count" do
    participants =
      stairs_with_two_participants()
      |> Stairs.add_participant("Elvis")
      |> Stairs.pair("Vitor", "Kenya")
      |> get_participants()

    assert Map.get(participants, "Vitor") == %{"Kenya" => 1, "Elvis" => 0}
    assert Map.get(participants, "Kenya") == %{"Vitor" => 1, "Elvis" => 0}
  end

  test "Undo pairing two participants automatically undos their pair count" do
    participants =
      stairs_with_two_participants()
      |> Stairs.add_participant("Elvis")
      |> Stairs.pair("Vitor", "Kenya")
      |> Stairs.unpair("Vitor", "Kenya")
      |> get_participants()

    assert Map.get(participants, "Vitor") == %{"Kenya" => 0, "Elvis" => 0}
    assert Map.get(participants, "Kenya") == %{"Vitor" => 0, "Elvis" => 0}
  end

  test "Should not allow to unpair if they never paired" do
    participants =
      stairs_with_two_participants()
      |> Stairs.unpair("Vitor", "Kenya")
      |> get_participants()

    assert Map.get(participants, "Vitor") == %{"Kenya" => 0}
    assert Map.get(participants, "Kenya") == %{"Vitor" => 0}
  end

  test "Should be able to reset stairs" do
    participants =
      stairs_with_two_participants()
      |> Stairs.pair("Vitor", "Kenya")
      |> Stairs.reset_all_counters()
      |> get_participants()

    assert Map.get(participants, "Vitor") == %{"Kenya" => 0}
    assert Map.get(participants, "Kenya") == %{"Vitor" => 0}
  end

  test "Should allow removing a participant" do
    participants =
      stairs_with_two_participants()
      |> Stairs.add_participant("Elvis")
      |> Stairs.remove_participant("Vitor")
      |> get_participants()

    assert Map.has_key?(participants, "Vitor") == false
    assert Map.get(participants, "Kenya") == %{"Elvis" => 0}
    assert Map.get(participants, "Elvis") == %{"Kenya" => 0}
  end

  test "Should limit maximum of pairing between participants" do
    {:error, msg} =
      Stairs.new("Limited Stairs", limit: 2)
      |> Stairs.add_participant("Elvis")
      |> Stairs.add_participant("Vitor")
      |> Stairs.pair("Elvis", "Vitor")
      |> Stairs.pair("Elvis", "Vitor")
      |> Stairs.pair("Elvis", "Vitor")

    assert msg == "maximum_limit_reached"
  end

  test "Should result error when pairing unknown participants" do
    {:error, msg} =
      stairs_with_two_participants()
      |> Stairs.pair("Notregistered", "Kenya")

    assert msg == "unknown_participant"
  end

  test "Should result error when unpairing unknown participants" do
    {:error, msg} =
      stairs_with_two_participants()
      |> Stairs.unpair("Notregistered", "Kenya")

    assert msg == "unknown_participant"
  end

  defp stairs_with_two_participants() do
    Stairs.new("Old Stairs")
    |> Stairs.add_participant("Vitor")
    |> Stairs.add_participant("Kenya")
  end

  defp get_participants(stairs), do: Map.get(stairs, :participants)
end

defmodule Parear.StairsTest do
  use ExUnit.Case
  doctest Parear.Stairs
  alias Parear.Stairs

  test "Creates a new stairs with id and name" do
    stairs = Stairs.new("Whiskey")
    assert stairs.name == "Whiskey"
    assert stairs.id != nil
  end

  test "Adds person with no matching pair" do
    stairs =
      Stairs.new("Another")
      |> Stairs.add_person("Vitor")
    
    assert Enum.empty?(stairs.persons) == false
    assert Map.get(stairs.persons, "Vitor") == %{}
  end

  test "Adding a second person automatically matches with everybody else" do
    stairs = stairs_with_two_persons()
    assert Enum.count(stairs.persons) == 2
    assert Map.get(stairs.persons, "Vitor") == %{"Kenya" => 0}
    assert Map.get(stairs.persons, "Kenya") == %{"Vitor" => 0}
  end

  test "Pairing two persons automatically updates their pair count" do
    persons =
      stairs_with_two_persons()
      |> Stairs.add_person("Elvis")
      |> Stairs.pair("Vitor", "Kenya")
      |> get_persons()

    assert Map.get(persons, "Vitor") == %{"Kenya" => 1, "Elvis" => 0}
    assert Map.get(persons, "Kenya") == %{"Vitor" => 1, "Elvis" => 0}
  end

  test "Undo pairing two persons automatically undos their pair count" do
    persons =
      stairs_with_two_persons()
      |> Stairs.add_person("Elvis")
      |> Stairs.pair("Vitor", "Kenya")
      |> Stairs.unpair("Vitor", "Kenya")
      |> get_persons()

    assert Map.get(persons, "Vitor") == %{"Kenya" => 0, "Elvis" => 0}
    assert Map.get(persons, "Kenya") == %{"Vitor" => 0, "Elvis" => 0}
  end

  test "Should not allow to unpair if they never paired" do
    persons =
      stairs_with_two_persons()
      |> Stairs.unpair("Vitor", "Kenya")
      |> get_persons()

    assert Map.get(persons, "Vitor") == %{"Kenya" => 0}
    assert Map.get(persons, "Kenya") == %{"Vitor" => 0}
  end

  test "Should be able to reset stairs" do
    persons =
      stairs_with_two_persons()
      |> Stairs.pair("Vitor", "Kenya")
      |> Stairs.reset_all_counters()
      |> get_persons()

    assert Map.get(persons, "Vitor") == %{"Kenya" => 0}
    assert Map.get(persons, "Kenya") == %{"Vitor" => 0}
  end

  test "Should allow removing a person" do
    persons =
      stairs_with_two_persons()
      |> Stairs.add_person("Elvis")
      |> Stairs.remove_person("Vitor")
      |> get_persons()

    assert Map.has_key?(persons, "Vitor") == false
    assert Map.get(persons, "Kenya") == %{"Elvis" => 0}
    assert Map.get(persons, "Elvis") == %{"Kenya" => 0}
  end

  @tag :pending
  test "Should limit maximum of pairing between participants" do
    {:error, msg} =
      Stairs.new("Limited Stairs", limit: 2)
      |> Stairs.add_person("Elvis")
      |> Stairs.add_person("Vitor")
      |> Stairs.pair("Elvis", "Vitor")
      |> Stairs.pair("Elvis", "Vitor")
      |> Stairs.pair("Elvis", "Vitor")

    assert msg == "limit_reached"
  end
 
  defp stairs_with_two_persons() do
    Stairs.new("Old Stairs")
    |> Stairs.add_person("Vitor")
    |> Stairs.add_person("Kenya")
  end

  defp get_persons(stairs), do: Map.get(stairs, :persons)
end

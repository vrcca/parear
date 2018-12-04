defmodule ParearTest do
  use ExUnit.Case
  doctest Parear

  test "Creates a new stairs with id and name" do
    stairs = Parear.create_stairs("Whiskey")
    assert stairs.name == "Whiskey"
    assert stairs.id != nil
  end

  test "Adds person with no matching pair" do
    stairs = Parear.create_stairs("Another")
    |> Parear.add_person("Vitor")
    assert Enum.empty?(stairs.persons) == false
    assert Map.get(stairs.persons, "Vitor") == %{}
  end

  test "Adding a second person automatically matches with everybody else" do
    stairs = Parear.create_stairs("Another")
    |> Parear.add_person("Vitor")
    |> Parear.add_person("Kenya")
    assert Enum.count(stairs.persons) == 2
    assert Map.get(stairs.persons, "Vitor") == %{ "Kenya" => 0 }
    assert Map.get(stairs.persons, "Kenya") == %{ "Vitor" => 0 }
  end

  test "Pairing two persons automatically updates their pair count" do
    persons = Parear.create_stairs("Another")
    |> Parear.add_person("Vitor")
    |> Parear.add_person("Kenya")
    |> Parear.add_person("Elvis")
    |> Parear.pair("Vitor", "Kenya")
    |> Map.get(:persons)
    assert Map.get(persons, "Vitor") == %{ "Kenya" => 1, "Elvis" => 0 }
    assert Map.get(persons, "Kenya") == %{ "Vitor" => 1, "Elvis" => 0 }
  end

  test "Undo pairing two persons automatically undos their pair count" do
    persons = Parear.create_stairs("Another")
    |> Parear.add_person("Vitor")
    |> Parear.add_person("Kenya")
    |> Parear.add_person("Elvis")
    |> Parear.pair("Vitor", "Kenya")
    |> Parear.unpair("Vitor", "Kenya")
    |> Map.get(:persons)
    assert Map.get(persons, "Vitor") == %{ "Kenya" => 0, "Elvis" => 0 }
    assert Map.get(persons, "Kenya") == %{ "Vitor" => 0, "Elvis" => 0 }
  end
    
  test "Should not allow to unpair if they never paired" do
    persons = Parear.create_stairs("Another")
    |> Parear.add_person("Vitor")
    |> Parear.add_person("Kenya")
    |> Parear.unpair("Vitor", "Kenya")
    |> Map.get(:persons)
    assert Map.get(persons, "Vitor") == %{ "Kenya" => 0 }
    assert Map.get(persons, "Kenya") == %{ "Vitor" => 0 }
  end
    
end

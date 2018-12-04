defmodule Parear do

  defstruct id: nil, name: nil, persons: []

  def create_stairs(name) do
    %Parear{ id: UUID.uuid4(),
             name: name,
             persons: %{}
    }
  end

  def add_person(stairs = %Parear{ persons: current_persons }, name) do
    updated_persons = matching_new_pairs(current_persons, name)
    %{ stairs | persons: updated_persons }
  end

  def pair(stairs, person, another_person) do
    update_pair_count(stairs, person, another_person, &(&1 + 1))
  end

  def unpair(stairs, person, another_person) do
    update_pair_count(stairs, person, another_person, &(&1 - 1))
  end

  ##### Helping functions ####
  
  defp matching_new_pairs(persons, new_person) do
    Map.keys(persons)
    |> add_new_person_to_all(persons, new_person)
    |> Map.put(new_person, all_possible_matches(persons))
  end

  defp add_new_person_to_all(participants, persons, new_person) do
    Enum.reduce(participants, persons, fn (participant, state) ->
      Map.update(state, participant, %{}, &(Map.put(&1, new_person, 0)))
    end)
  end

  defp all_possible_matches(persons) do
    persons
    |> Map.keys
    |> Map.new(fn key -> {key, 0} end)
  end

  def get_and_update(data, key, fun) do
    {current, updated} = fun.(Map.get(data, key))
    {current, Map.put(data, key, updated)}
  end
  
  defp update_pair_count(stairs, person, another_person, fun) do
    stairs
    |> update_in([:persons, person, another_person], fun)
    |> update_in([:persons, another_person, person], fun)
  end
end

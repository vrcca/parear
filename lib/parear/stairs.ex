defmodule Parear.Stairs do
  alias Parear.Stairs

  defstruct id: nil, name: nil, persons: [], limit: :infinity

  def new(name, opts) do
    limit = Keyword.get(opts, :limit, :infinity)
    %Stairs{id: UUID.uuid4(), name: name, persons: %{}, limit: limit}
  end

  def add_person(stairs = %Stairs{persons: current_persons}, name) do
    updated_persons = matching_new_pairs(current_persons, name)
    %{stairs | persons: updated_persons}
  end

  def remove_person(stairs, name) do
    stairs
    |> remove_from_persons(name)
    |> remove_from_each_participant(name)
  end

  def pair(stairs, person, another_person) do
    update_pair_count(stairs, person, another_person, &(&1 + 1))
  end

  def unpair(stairs, person, another_person) do
    update_pair_count(stairs, person, another_person, &subtract_pair/1)
  end

  def reset_all_counters(stairs = %Stairs{persons: persons}) do
    empty_stairs = update_in(stairs, [:persons], fn _ -> %{} end)

    persons
    |> Map.keys()
    |> Enum.reduce(empty_stairs, fn person, current_stairs ->
      add_person(current_stairs, person)
    end)
  end

  ##### Helping functions ####

  defp subtract_pair(0), do: 0
  defp subtract_pair(x), do: x - 1

  defp matching_new_pairs(persons, new_person) do
    Map.keys(persons)
    |> add_new_person_to_all(persons, new_person)
    |> Map.put(new_person, all_possible_matches(persons))
  end

  defp add_new_person_to_all(participants, persons, new_person) do
    Enum.reduce(participants, persons, fn participant, state ->
      Map.update(state, participant, %{}, &Map.put(&1, new_person, 0))
    end)
  end

  defp all_possible_matches(persons) do
    persons
    |> Map.keys()
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

  defp remove_from_persons(stairs, name) do
    update_in(stairs, [:persons], &Map.drop(&1, [name]))
  end

  defp remove_from_each_participant(stairs = %Stairs{persons: participants}, name) do
    participants
    |> Enum.reduce(stairs, fn {participant, _friends}, current_stairs ->
      update_in(current_stairs, [:persons, participant], fn friends ->
        Map.drop(friends, [name])
      end)
    end)
  end
end

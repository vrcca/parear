defmodule Parear.Stairs do
  alias Parear.{Stairs, Validations}

  defstruct id: nil, name: nil, participants: [], limit: :infinity

  def new(name, opts \\ []) do
    limit = Keyword.get(opts, :limit, :infinity)
    %Stairs{id: UUID.uuid4(), name: name, participants: %{}, limit: limit}
  end

  def add_participant(stairs = %Stairs{participants: participants}, name) do
    Map.put(stairs, :participants, matching_new_pairs(participants, name))
  end

  def remove_participant(stairs, name) do
    stairs
    |> remove(name)
    |> remove_from_each_participant(name)
  end

  def pair(stairs, name, another_name) do
    validation = Validations.prepare_with(stairs, name, another_name)

    with {:ok, _} <- validation.(:participants_exist),
         {:ok, _} <- validation.(:pair_limit) do
      {:ok, update_pair_count(stairs, name, another_name, &(&1 + 1))}
    end
  end

  def unpair(stairs, name, another_name) do
    validation = Validations.prepare_with(stairs, name, another_name)

    with {:ok, _} <- validation.(:participants_exist) do
      {:ok, update_pair_count(stairs, name, another_name, &max(&1 - 1, 0))}
    end
  end

  def reset_all_counters(stairs = %Stairs{participants: participants}) do
    empty_stairs = update_in(stairs, [:participants], fn _ -> %{} end)

    participants
    |> Map.keys()
    |> Enum.reduce(empty_stairs, fn participant, current_stairs ->
      add_participant(current_stairs, participant)
    end)
  end

  ##### Helping functions ####

  defp matching_new_pairs(participants, new_participant) do
    Map.keys(participants)
    |> add_new_participant_to_all(participants, new_participant)
    |> Map.put(new_participant, all_possible_matches(participants))
  end

  defp add_new_participant_to_all(names, participants, new_participant) do
    Enum.reduce(names, participants, fn participant, state ->
      Map.update(state, participant, %{}, &Map.put(&1, new_participant, 0))
    end)
  end

  defp all_possible_matches(participants) do
    participants
    |> Map.keys()
    |> Map.new(fn key -> {key, 0} end)
  end

  def get_and_update(data, key, fun) do
    {current, updated} = fun.(Map.get(data, key))
    {current, Map.put(data, key, updated)}
  end

  defp update_pair_count(stairs, participant, another_participant, fun) do
    updated_value = fun.(stairs.participants[participant][another_participant])

    stairs
    |> update_in([:participants, participant, another_participant], fn _ -> updated_value end)
    |> update_in([:participants, another_participant, participant], fn _ -> updated_value end)
  end

  defp remove(stairs, name) do
    update_in(stairs, [:participants], &Map.drop(&1, [name]))
  end

  defp remove_from_each_participant(stairs = %Stairs{participants: participants}, name) do
    participants
    |> Enum.reduce(stairs, fn {participant, _friends}, current_stairs ->
      update_in(current_stairs, [:participants, participant], fn friends ->
        Map.drop(friends, [name])
      end)
    end)
  end
end
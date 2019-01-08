defmodule Parear.Stairs do
  alias Parear.{Stairs, Participant, Validations}

  defstruct id: nil,
            name: nil,
            limit: :infinity,
            all_participants: [],
            statuses: %{},
            participants: []

  def new(name, opts \\ []) do
    limit = Keyword.get(opts, :limit, :infinity)

    %Stairs{
      id: UUID.uuid4(),
      name: name,
      limit: limit,
      participants: %{},
      statuses: %{},
      all_participants: []
    }
  end

  def add_participant(
        stairs = %Stairs{participants: participants, statuses: statuses},
        new_participant = %Participant{}
      ) do
    Map.update(stairs, :all_participants, [], fn participants ->
      [new_participant | participants]
    end)
    |> Map.put(:participants, matching_new_pairs(participants, new_participant.name))
    |> Map.put(:statuses, matching_new_pairs(statuses, new_participant.id))
  end

  def add_participant(stairs = %Stairs{}, name) do
    new_participant = Participant.new(name)

    stairs
    |> add_participant(new_participant)
  end

  def find_participant_by_name(%Stairs{all_participants: participants}, name) do
    participants
    |> Enum.find(fn %Participant{name: participant_name} ->
      participant_name == name
    end)
  end

  def find_participant_by_id(stairs = %Stairs{}, id) do
    stairs.all_participants
    |> Enum.find(fn participant ->
      participant.id == id
    end)
  end

  def find_participant_by(%Stairs{all_participants: participants}, property, value)
      when is_atom(property) do
    participants
    |> Enum.find(fn participant ->
      Map.get(participant, property) == value
    end)
  end

  def statuses_for_participant(%Stairs{statuses: statuses}, %Participant{id: searched}) do
    {_, status} =
      statuses
      |> Enum.find({searched, %{}}, fn {id, _status} ->
        searched == id
      end)

    status
  end

  def remove_participant(stairs = %Stairs{}, participant = %Participant{}) do
    stairs
    |> remove(participant)
    |> remove_from_each_participant(:participants, participant.name)
    |> remove_from_each_participant(:statuses, participant.id)
  end

  def remove_participant(stairs = %Stairs{}, name) do
    participant = find_participant_by_name(stairs, name)
    remove_participant(stairs, participant)
  end

  def pair(stairs, name, another_name) do
    participant = find_participant_by_name(stairs, name)
    another_participant = find_participant_by_name(stairs, another_name)
    validation = Validations.prepare_with(stairs, participant, another_participant)

    with {:ok, _} <- validation.(:participants_exist),
         {:ok, _} <- validation.(:pair_limit) do
      updated_stairs =
        stairs
        |> update_pair_count(name, another_name, &(&1 + 1))
        |> update_pair_count(participant, another_participant, &(&1 + 1))

      {:ok, updated_stairs}
    end
  end

  def unpair(stairs, name, another_name) do
    participant = find_participant_by_name(stairs, name)
    another_participant = find_participant_by_name(stairs, another_name)
    validation = Validations.prepare_with(stairs, participant, another_participant)

    with {:ok, _} <- validation.(:participants_exist) do
      updated_stairs =
        stairs
        |> update_pair_count(name, another_name, &max(&1 - 1, 0))
        |> update_pair_count(participant, another_participant, &max(&1 - 1, 0))

      {:ok, updated_stairs}
    end
  end

  def reset_all_counters(stairs = %Stairs{statuses: statuses}) do
    empty_stairs =
      update_in(stairs, [:participants], fn _ -> %{} end)
      |> update_in([:statuses], fn _ -> %{} end)

    statuses
    |> Map.keys()
    |> Enum.reduce(empty_stairs, fn id, current_stairs ->
      participant = find_participant_by_id(empty_stairs, id)
      add_participant(current_stairs, participant)
    end)
  end

  ##### Helping functions ####

  defp matching_new_pairs(statuses, id) do
    statuses
    |> Map.keys()
    |> add_new_participant_to_all(statuses, id)
    |> Map.put(id, all_possible_matches(statuses))
  end

  defp add_new_participant_to_all(ids, participants, new_participant) do
    Enum.reduce(ids, participants, fn participant, state ->
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

  defp update_pair_count(
         stairs,
         participant = %Participant{id: id},
         %Participant{id: another_id},
         fun
       ) do
    statuses = statuses_for_participant(stairs, participant)
    current_value = statuses[another_id]
    updated_value = fun.(current_value)

    stairs
    |> update_in([:statuses, id, another_id], fn _ -> updated_value end)
    |> update_in([:statuses, another_id, id], fn _ -> updated_value end)
  end

  defp update_pair_count(stairs, participant, another_participant, fun) do
    updated_value = fun.(stairs.participants[participant][another_participant])

    stairs
    |> update_in([:participants, participant, another_participant], fn _ -> updated_value end)
    |> update_in([:participants, another_participant, participant], fn _ -> updated_value end)
  end

  defp remove(stairs, participant = %Participant{name: name}) do
    update_in(stairs, [:participants], &Map.drop(&1, [name]))
    |> update_in([:all_participants], &List.delete(&1, participant))
  end

  defp remove_from_each_participant(stairs, property, id) do
    stairs
    |> Map.get(property)
    |> Enum.reduce(stairs, fn {name, _friends}, current_stairs ->
      update_in(current_stairs, [property, name], fn friends ->
        Map.drop(friends, [id])
      end)
    end)
  end
end

defmodule Parear.Stairs do
  alias Parear.{Stairs, Participant, Validations}

  @default_limit 5
  defstruct id: nil,
            name: nil,
            limit: @default_limit,
            participants: %{},
            statuses: %{}

  def new(name, opts \\ []) do
    limit = Keyword.get(opts, :limit, @default_limit)

    %Stairs{
      id: UUID.uuid4(),
      name: name,
      limit: limit,
      statuses: %{},
      participants: %{}
    }
  end

  def add_participant(
        stairs = %Stairs{},
        new_participant = %Participant{id: id}
      ) do
    Map.update(stairs, :participants, %{}, fn participants ->
      Map.put(participants, id, new_participant)
    end)
    |> add_to_statuses(id)
  end

  def add_participant(stairs = %Stairs{}, name),
    do: add_participant(stairs, Participant.new(name))

  def find_participant_by_name(%Stairs{participants: participants}, name) do
    found_participant =
      participants
      |> Enum.find(fn {_id, %Participant{name: participant_name}} ->
        participant_name == name
      end)

    case found_participant do
      {_id, participant} -> participant
      nil -> nil
    end
  end

  defp find_participant(stairs, term) do
    case find_participant_by_id(stairs, term) do
      nil -> find_participant_by_name(stairs, term)
      p -> p
    end
  end

  def find_participant_by_id(%Stairs{participants: participants}, id) do
    Map.get(participants, id)
  end

  def find_participant_by(%Stairs{participants: participants}, property, value)
      when is_atom(property) do
    participants
    |> Enum.find(fn {_id, participant} ->
      Map.get(participant, property) == value
    end)
  end

  def statuses_for_participant(%Stairs{statuses: statuses}, %Participant{id: searched}) do
    {_, status} =
      statuses
      |> Enum.find({:not_found, nil}, fn {id, _status} ->
        searched == id
      end)

    status
  end

  def remove_participant(stairs = %Stairs{}, participant = %Participant{}) do
    stairs
    |> remove(participant)
    |> remove_from_each_participant(:statuses, participant.id)
    |> remove_participant_statuses(participant)
    |> clean_up_single_participant_statuses()
  end

  def remove_participant(stairs = %Stairs{}, name) do
    participant = find_participant(stairs, name)
    remove_participant(stairs, participant)
  end

  def pair(stairs = %Stairs{}, id, another_id) do
    participant = find_participant(stairs, id)
    another_participant = find_participant(stairs, another_id)
    validation = Validations.prepare_with(stairs, participant, another_participant)

    with {:ok, _} <- validation.(:participants_exist),
         {:ok, _} <- validation.(:pair_limit) do
      updated_stairs =
        stairs
        |> update_pair_count(participant, another_participant, &(&1 + 1))

      {:ok, updated_stairs}
    end
  end

  def unpair(stairs = %Stairs{}, name, another_name) do
    participant = find_participant(stairs, name)
    another_participant = find_participant(stairs, another_name)
    validation = Validations.prepare_with(stairs, participant, another_participant)

    with {:ok, _} <- validation.(:participants_exist) do
      updated_stairs =
        stairs
        |> update_pair_count(participant, another_participant, &max(&1 - 1, 0))

      {:ok, updated_stairs}
    end
  end

  def reset_all_counters(stairs = %Stairs{statuses: statuses}) do
    %{stairs | statuses: reset_matches(statuses)}
  end

  defp reset_matches(statuses) do
    Enum.reduce(statuses, %{}, fn {id, matches}, acc ->
      Map.put(acc, id, Enum.into(matches, %{}, &put_elem(&1, 1, 0)))
    end)
  end

  ##### Helping functions ####

  defp add_to_statuses(stairs = %Stairs{participants: participants}, _id)
       when map_size(participants) == 1 do
    stairs
  end

  defp add_to_statuses(stairs = %Stairs{participants: participants, statuses: statuses}, new_id)
       when map_size(participants) == 2 and map_size(statuses) == 0 do
    statuses =
      participants
      |> get_first_id_different_from(new_id)
      |> empty_statuses()

    stairs
    |> Map.put(:statuses, statuses)
    |> add_to_statuses(new_id)
  end

  defp add_to_statuses(stairs = %Stairs{statuses: statuses}, id) do
    stairs
    |> Map.put(:statuses, matching_new_pairs(statuses, id))
  end

  defp get_first_id_different_from(participants, new_id) do
    [first | _rest] =
      participants
      |> Map.delete(new_id)
      |> Map.keys()

    first
  end

  defp empty_statuses(id) do
    %{id => %{}}
  end

  defp matching_new_pairs(statuses, id) do
    statuses
    |> Map.keys()
    |> add_new_participant_to_all(statuses, id)
    |> Map.put(id, all_possible_matches(statuses))
  end

  defp add_new_participant_to_all(ids, participants, new_participant) do
    ids
    |> Enum.reduce(participants, fn participant, state ->
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
    current_value = statuses[another_id] || 0
    updated_value = fun.(current_value)

    stairs
    |> create_statuses_if_not_exists(id)
    |> create_statuses_if_not_exists(another_id)
    |> update_in([:statuses, id, another_id], fn _ -> updated_value end)
    |> update_in([:statuses, another_id, id], fn _ -> updated_value end)
  end

  defp create_statuses_if_not_exists(stairs = %Stairs{statuses: statuses}, id) do
    statuses[id]
    |> case do
      nil -> stairs |> update_in([:statuses, id], fn _ -> %{} end)
      _ -> stairs
    end
  end

  defp remove(stairs, %Participant{id: id}) do
    update_in(stairs, [:participants], fn participants ->
      Map.drop(participants, [id])
    end)
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

  defp remove_participant_statuses(stairs = %Stairs{statuses: statuses}, %Participant{id: id}) do
    %{stairs | statuses: Map.delete(statuses, id)}
  end

  defp clean_up_single_participant_statuses(stairs = %Stairs{participants: participants})
       when map_size(participants) == 1 do
    %{stairs | statuses: %{}}
  end

  defp clean_up_single_participant_statuses(stairs), do: stairs
end

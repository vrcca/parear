defmodule Parear.Server do
  use GenServer

  alias Parear.{Stairs, Participant, ParticipantRepository, Repository}

  def start_link(stairs = %Stairs{id: id}) do
    name = {:via, Registry, {Registry.Stairs, id}}
    GenServer.start_link(__MODULE__, stairs, name: name)
  end

  def start_link(args = %{id: id}) do
    name = {:via, Registry, {Registry.Stairs, id}}
    GenServer.start_link(__MODULE__, args, name: name)
  end

  def init(stairs = %Stairs{}) do
    stairs
    |> reply_init()
  end

  def init(%{id: id}) do
    {:ok, %Stairs{id: id}, {:continue, :init_by_stairs_id}}
  end

  def handle_continue(:init_by_stairs_id, stairs_with_id = %Stairs{}) do
    stairs_with_id
    |> Repository.find_by_id()
    |> case do
      {:none} ->
        {:stop, :stairs_could_not_be_found, stairs_with_id}

      {:ok, stairs = %Stairs{}} ->
        {:noreply, stairs}
    end
  end

  def handle_call({:add_participant, name}, _from, stairs) do
    with new_participant <- Participant.new(name),
         updated_stairs <- Stairs.add_participant(stairs, new_participant),
         {:ok, _} <- ParticipantRepository.insert(new_participant, updated_stairs) do
      updated_stairs
      |> reply_ok()
    end
  end

  def handle_call({:pair, participant, another}, _from, stairs) do
    with {:ok, updated_stairs} <- Stairs.pair(stairs, participant, another) do
      updated_stairs
      |> Repository.save()
      |> handle_result(stairs)
    end
  end

  def handle_call({:unpair, participant, another}, _from, stairs) do
    with {:ok, updated_stairs} <- Stairs.unpair(stairs, participant, another) do
      updated_stairs
      |> Repository.save()
      |> handle_result(stairs)
    end
  end

  def handle_call({:remove_participant, name}, _from, stairs) do
    Stairs.remove_participant(stairs, name)
    |> Repository.save()
    |> reply_ok()
  end

  def handle_call({:remove_participant_by_id, id}, _from, stairs) do
    participant = stairs |> Stairs.find_participant_by_id(id)

    Stairs.remove_participant(stairs, participant)
    |> Repository.save()
    |> reply_ok()
  end

  def handle_call({:save}, _from, stairs) do
    stairs
    |> Repository.save()
    |> reply_ok()
  end

  def handle_call({:reset_counters}, _from, stairs) do
    Stairs.reset_all_counters(stairs)
    |> Repository.save()
    |> reply_ok()
  end

  def handle_call({:list}, _from, current_stairs) do
    {:reply, {:ok, current_stairs}, current_stairs}
  end

  defp handle_result(error = {:error, _msg}, stairs) do
    {:reply, error, stairs}
  end

  defp handle_result({:ok, updated_stairs}, _stairs) do
    reply_ok(updated_stairs)
  end

  defp handle_result(updated_stairs, _stairs) do
    reply_ok(updated_stairs)
  end

  defp reply_ok(updated_stairs) do
    %{statuses: statuses} = updated_stairs

    statuses =
      statuses
      |> convert_using_participants(updated_stairs.participants)

    {:reply, {:ok, %{stairs: statuses}}, updated_stairs}
  end

  defp convert_using_participants(statuses, participants) do
    find = fn id ->
      Map.get(participants, id)
    end

    statuses
    |> Enum.reduce(%{}, fn {id, friends}, acc ->
      converted_friends =
        Enum.reduce(friends, %{}, fn {friend_id, total}, friends_acc ->
          friends_acc |> Map.put(find.(friend_id), total)
        end)

      Map.put(acc, find.(id), converted_friends)
    end)
  end

  defp reply_init({:none}), do: {:stop, :stairs_could_not_be_found}
  defp reply_init({:ok, stairs}), do: {:ok, stairs}
  defp reply_init(stairs = %Stairs{}), do: {:ok, stairs}
end
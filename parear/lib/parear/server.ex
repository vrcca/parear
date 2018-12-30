defmodule Parear.Server do
  use GenServer

  alias Parear.{Stairs, Repository}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(%{name: name, options: options}) do
    new_stairs =
      Stairs.new(name, options)
      |> Repository.save()

    {:ok, new_stairs}
  end

  def init(%{id: id}) do
    Repository.find_by_id(%Stairs{id: id})
  end

  def handle_call({:add_participant, name}, _from, stairs) do
    Stairs.add_participant(stairs, name)
    |> Repository.save()
    |> reply_ok()
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
    %{participants: participants} = updated_stairs
    {:reply, {:ok, %{stairs: participants}}, updated_stairs}
  end
end

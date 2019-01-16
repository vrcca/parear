defmodule Parear do
  def new_stairs(name, options \\ []) do
    start_stairs(%{name: name, options: options})
    |> reply()
  end

  def reload_by_id(id) do
    start_stairs(%{id: id})
  end

  def reload(id) do
    start_stairs(%{id: id})
    |> reply()
  end

  def reload_by_name(name) do
    start_stairs(%{name: name})
    |> reply()
  end

  def add_participant(stairs, name) do
    GenServer.call(stairs, {:add_participant, name})
  end

  def pair(stairs, participant, another_participant) do
    GenServer.call(stairs, {:pair, participant, another_participant})
  end

  def unpair(stairs, participant, another_participant) do
    GenServer.call(stairs, {:unpair, participant, another_participant})
  end

  def reset_all_counters(stairs) do
    GenServer.call(stairs, {:reset_counters})
  end

  def remove_participant(stairs, name) do
    GenServer.call(stairs, {:remove_participant, name})
  end

  def list(stairs) do
    GenServer.call(stairs, {:list})
  end

  ## Helper methods
  defp start_stairs(args = %{}) do
    spec = {Parear.Server, args}
    DynamicSupervisor.start_child(Parear.DynamicSupervisor, spec)
  end

  defp reply({:ok, pid}), do: pid
  defp reply(error = {:error, _reason}), do: error
end

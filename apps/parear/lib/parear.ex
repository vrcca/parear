defmodule Parear do
  alias Parear.Loader

  def new_stairs(name, options \\ []) do
    Loader.create(name, options)
  end

  def reload_by_id(id) do
    Loader.load_by_id(id)
  end

  def add_participant(stairs, name) do
    stairs
    |> ensure_running()
    |> call({:add_participant, name})
  end

  def pair(stairs, participant, another_participant) do
    stairs
    |> ensure_running()
    |> call({:pair, participant, another_participant})
  end

  def unpair(stairs, participant, another_participant) do
    stairs
    |> ensure_running()
    |> call({:unpair, participant, another_participant})
  end

  def reset_all_counters(stairs) do
    stairs
    |> ensure_running()
    |> call({:reset_counters})
  end

  def remove_participant(stairs, name) do
    GenServer.call(from_registry(stairs), {:remove_participant, name})
  end

  def remove_participant_by_id(stairs, id) do
    stairs
    |> ensure_running()
    |> call({:remove_participant_by_id, id})
  end

  def list(stairs) do
    stairs
    |> ensure_running()
    |> call({:list})
  end

  defp ensure_running(stairs) do
    Registry.lookup(Registry.Stairs, stairs)
    |> case do
      _no_pid_found = [] -> reload_by_id(stairs)
      _pid_found -> stairs
    end
  end

  defp call(stairs, args) when is_binary(stairs) do
    from_registry(stairs)
    |> GenServer.call(args)
  end

  defp call(other, _args) do
    other
  end

  defp from_registry(stairs_id) when is_binary(stairs_id) do
    {:via, Registry, {Registry.Stairs, stairs_id}}
  end
end

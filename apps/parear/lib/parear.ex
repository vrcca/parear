defmodule Parear do
  alias Parear.Loader

  def new_stairs(name, options \\ []) do
    Loader.create(name, options)
  end

  def reload_by_id(id) do
    Loader.load_by_id(id)
  end

  def add_participant(stairs, name) do
    ensure_call(stairs, {:add_participant, name})
  end

  def pair(stairs, participant, another_participant) do
    ensure_call(stairs, {:pair, participant, another_participant})
  end

  def unpair(stairs, participant, another_participant) do
    ensure_call(stairs, {:unpair, participant, another_participant})
  end

  def reset_all_counters(stairs) do
    ensure_call(stairs, {:reset_counters})
  end

  def remove_participant(stairs, name) do
    GenServer.call(from_registry(stairs), {:remove_participant, name})
  end

  def remove_participant_by_id(stairs, id) do
    ensure_call(stairs, {:remove_participant_by_id, id})
  end

  def list(stairs) do
    ensure_call(stairs, {:list})
  end

  defp ensure_call(stairs, args) do
    stairs
    |> ensure_running()
    |> call(args)
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

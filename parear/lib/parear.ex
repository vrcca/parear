defmodule Parear do
  alias Parear.Loader

  def new_stairs(name, options \\ []) do
    Loader.create(name, options)
  end

  def reload_by_id(id) do
    Loader.load_by_id(id)
  end

  # deprecated: for text_client only. to be removed once web is done
  def reload_by_name(name) do
    Loader.load_by_name(name)
  end

  def add_participant(stairs, name) do
    GenServer.call(from_registry(stairs), {:add_participant, name})
  end

  def pair(stairs, participant, another_participant) do
    GenServer.call(from_registry(stairs), {:pair, participant, another_participant})
  end

  def unpair(stairs, participant, another_participant) do
    GenServer.call(from_registry(stairs), {:unpair, participant, another_participant})
  end

  def reset_all_counters(stairs) do
    GenServer.call(from_registry(stairs), {:reset_counters})
  end

  def remove_participant(stairs, name) do
    GenServer.call(from_registry(stairs), {:remove_participant, name})
  end

  def remove_participant_by_id(stairs, id) do
    stairs
    |> ensure_running()
    |> GenServer.call({:remove_participant_by_id, id})
  end

  def list(stairs) do
    stairs
    |> ensure_running()
    |> GenServer.call({:list})
  end

  defp from_registry(stairs_id) do
    {:via, Registry, {Registry.Stairs, stairs_id}}
  end

  defp ensure_running(stairs) do
    Registry.lookup(Registry.Stairs, stairs)
    |> case do
      _no_pid_found = [] -> reload_by_id(stairs)
      _pid_found -> stairs
    end
    |> from_registry()
  end
end

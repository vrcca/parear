defmodule Parear do
  def new_stairs(name, options \\ []) do
    spec = {Parear.Server, %{name: name, options: options}}
    {:ok, pid} = DynamicSupervisor.start_child(Parear.DynamicSupervisor, spec)
    pid
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
end

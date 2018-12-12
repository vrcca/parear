defmodule Parear do
  def new_stairs(name, opts \\ []) do
    {:ok, pid} = Parear.DynamicSupervisor.start_child(name, opts)
    pid
  end

  def add_person(stairs, name) do
    GenServer.call(stairs, {:add_person, name})
  end

  def pair(stairs, person, another_person) do
    GenServer.call(stairs, {:pair, person, another_person})
  end

  def unpair(stairs, person, another_person) do
    GenServer.call(stairs, {:unpair, person, another_person})
  end

  def reset_all_counters(stairs) do
    GenServer.call(stairs, {:reset_counters})
  end

  def remove_person(stairs, name) do
    GenServer.call(stairs, {:remove_person, name})
  end
end

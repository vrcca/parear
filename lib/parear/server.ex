defmodule Parear.Server do
  use GenServer

  alias Parear.Stairs

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(%{name: name, options: options}) do
    {:ok, Stairs.new(name, options)}
  end

  def handle_call({:add_person, name}, _from, stairs) do
    new_stairs = Stairs.add_person(stairs, name)
    {:reply, :ok, new_stairs}
  end

  def handle_call({:pair, person, another_person}, _from, stairs) do
    new_stairs = Stairs.pair(stairs, person, another_person)
    # TODO: handle unsuccessful pair
    {:reply, :ok, new_stairs}
  end

  def handle_call({:unpair, person, another_person}, _from, stairs) do
    new_stairs = Stairs.unpair(stairs, person, another_person)
    {:reply, :ok, new_stairs}
  end

  def handle_call({:remove_person, name}, _from, stairs) do
    new_stairs = Stairs.remove_person(stairs, name)
    {:reply, :ok, new_stairs}
  end

  def handle_call({:reset_counters}, _from, stairs) do
    new_stairs = Stairs.reset_all_counters(stairs)
    {:reply, :ok, new_stairs}
  end
end

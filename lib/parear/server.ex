defmodule Parear.Server do
  use GenServer

  alias Parear.Stairs

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(%{name: name, options: options}) do
    {:ok, Stairs.new(name, options)}
  end

  def handle_call({:add_participant, name}, _from, stairs) do
    Stairs.add_participant(stairs, name)
    |> reply_ok()
  end

  def handle_call({:pair, participant, another}, _from, stairs) do
    # TODO: handle unsuccessful pair
    Stairs.pair(stairs, participant, another)
    |> reply_ok()
  end

  def handle_call({:unpair, participant, another}, _from, stairs) do
    Stairs.unpair(stairs, participant, another)
    |> reply_ok()
  end

  def handle_call({:remove_participant, name}, _from, stairs) do
    Stairs.remove_participant(stairs, name)
    |> reply_ok()
  end

  def handle_call({:reset_counters}, _from, stairs) do
    Stairs.reset_all_counters(stairs)
    |> reply_ok()
  end

  def handle_call({:list}, _from, stairs) do
    reply_ok(stairs)
  end

  def reply_ok(new_state) do
    %{participants: participants} = new_state
    {:reply, {:ok, %{stairs: participants}}, new_state}
  end
end

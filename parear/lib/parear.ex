defmodule Parear do
  alias Parear.Stairs
  alias Parear.Repository

  def new_stairs(name, options \\ []) do
    Stairs.new(name, options)
    |> start_stairs()
    |> reply()
  end

  def reload_by_id(id) do
    start_stairs(%{id: id})
    |> reply()
  end

  def reload_by_name(name) do
    Repository.find_by_name(%Stairs{name: name})
    |> start_stairs()
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
  defp start_stairs({:ok, stairs = %Stairs{}}), do: start_stairs(stairs)
  defp start_stairs({:none}), do: reply({:error, :stairs_could_not_be_found})

  defp start_stairs(args) do
    spec = {Parear.Server, args}
    DynamicSupervisor.start_child(Parear.DynamicSupervisor, spec)
  end

  defp reply({:ok, pid}), do: pid
  defp reply({:error, {:already_started, pid}}), do: pid
  defp reply(error = {:error, _reason}), do: error
end

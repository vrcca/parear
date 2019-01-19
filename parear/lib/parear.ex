defmodule Parear do
  alias Parear.Stairs
  alias Parear.Repository

  def new_stairs(name, options \\ []) do
    with new_stairs <- Stairs.new(name, options),
         {:ok, stairs_pid} <- new_stairs |> start_stairs(),
         {:ok, _} <- stairs_pid |> save() do
      stairs_pid
      |> reply()
    end
  end

  def reload_by_id(id) do
    %{id: id}
    |> start_stairs()
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

  def save(stairs) do
    GenServer.call(stairs, {:save})
  end

  ## Helper methods
  defp start_stairs({:ok, stairs = %Stairs{}}), do: start_stairs(stairs)
  defp start_stairs({:none}), do: reply({:error, :stairs_could_not_be_found})
  defp start_stairs(stairs) when is_pid(stairs), do: {:ok, stairs}

  defp start_stairs(args) do
    spec = {Parear.Server, args}
    DynamicSupervisor.start_child(Parear.DynamicSupervisor, spec)
  end

  defp reply({:ok, pid}), do: reply(pid)
  defp reply({:error, {:already_started, pid}}), do: reply(pid)
  defp reply(pid) when is_pid(pid), do: pid
  defp reply(error = {:error, _reason}), do: error
end

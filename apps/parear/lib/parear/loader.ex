defmodule Parear.Loader do
  alias Parear.{Stairs}

  defp repository(), do: Application.get_env(:parear, :repository)

  def create(name, options \\ []) do
    with new_stairs <- Stairs.new(name, options),
         {:ok, _pid} <- new_stairs |> start_stairs(),
         {:ok, _} <- new_stairs.id |> save() do
      reply(new_stairs.id)
    end
  end

  def load_by_id(id) do
    %{id: id}
    |> start_stairs()
    |> reply()
  end

  def load_by_name(name) do
    repository().find_by_name(%Stairs{name: name})
    |> start_stairs()
    |> reply()
  end

  ## Helper methods
  defp start_stairs({:ok, stairs = %Stairs{}}), do: start_stairs(stairs)
  defp start_stairs({:none}), do: reply({:error, :stairs_could_not_be_found})
  defp start_stairs(stairs) when is_pid(stairs), do: {:ok, stairs}

  defp start_stairs(args) do
    spec = {Parear.Server, args}
    DynamicSupervisor.start_child(Parear.DynamicSupervisor, spec)
  end

  defp save(stairs) do
    GenServer.call(from_registry(stairs), {:save})
  end

  defp from_registry(stairs_id) do
    {:via, Registry, {Registry.Stairs, stairs_id}}
  end

  defp reply({:ok, pid}), do: reply(pid)

  defp reply(id) when is_pid(id) do
    try do
      {:ok, stairs} = GenServer.call(id, {:list})
      reply(stairs.id)
    catch
      :exit, e -> reply(e)
    end
  end

  defp reply({:error, {:already_started, pid}}), do: reply(pid)
  defp reply({:stairs_could_not_be_found, _}), do: {:error, :stairs_could_not_be_found}
  defp reply(error = {:error, _reason}) when is_tuple(error), do: error
  defp reply(id), do: id
end

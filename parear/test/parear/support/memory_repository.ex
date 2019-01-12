defmodule Parear.Support.MemoryRepository do
  alias Parear.{Stairs, Repository}

  use Agent

  @repo __MODULE__

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: @repo)
  end

  def get_by_id(id) do
    Agent.get(@repo, fn state ->
      Map.get(state, id)
    end)
  end

  def get_by_name(name) do
    Agent.get(@repo, fn state ->
      Enum.find(state, fn {_id, stairs} ->
        stairs.name == name
      end)
    end)
  end

  def save(stairs = %Stairs{id: id}) do
    Agent.update(@repo, fn state ->
      Map.put(state, id, stairs)
    end)
  end

  defimpl Repository, for: Stairs do
    def find_by_id(%Stairs{id: id}) do
      Parear.Support.MemoryRepository.get_by_id(id)
      |> respond_to_find()
    end

    def find_by_name(%Stairs{name: name}) do
      Parear.Support.MemoryRepository.get_by_name(name)
      |> respond_to_find()
    end

    def save(stairs = %Stairs{}) do
      with :ok <- Parear.Support.MemoryRepository.save(stairs) do
        stairs
      end
    end

    defp respond_to_find(nil), do: {:none}
    defp respond_to_find({_id, stairs}), do: {:ok, stairs}
    defp respond_to_find(stairs), do: {:ok, stairs}
  end
end

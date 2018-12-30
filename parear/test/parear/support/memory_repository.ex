defmodule Parear.Support.MemoryRepository do
  alias Parear.{Stairs, Repository}

  use Agent

  @repo __MODULE__

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: @repo)
  end

  def get(id) do
    Agent.get(@repo, fn state ->
      Map.get(state, id)
    end)
  end

  def save(stairs = %Stairs{id: id}) do
    Agent.update(@repo, fn state ->
      Map.put(state, id, stairs)
    end)
  end

  defimpl Repository, for: Stairs do
    def find_by_id(%Stairs{id: id}) do
      stairs = Parear.Support.MemoryRepository.get(id)
      {:ok, stairs}
    end

    def save(stairs = %Stairs{}) do
      with :ok <- Parear.Support.MemoryRepository.save(stairs) do
        stairs
      end
    end
  end
end

defmodule Repository.Stairs do
  use Agent

  @repo __MODULE__

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: @repo)
  end

  def find_by_id(id) do
    Agent.get(@repo, fn state ->
      Map.get(state, id)
    end)
  end

  def save(stairs = %Parear.Stairs{id: id}) do
    Agent.update(@repo, fn state ->
      Map.put(state, id, stairs)
    end)
  end
end

defimpl Parear.Repository, for: Parear.Stairs do
  def find_by_id(%Parear.Stairs{id: id}) do
    stairs = Repository.Stairs.find_by_id(id)
    {:ok, stairs}
  end

  def save(stairs = %Parear.Stairs{}) do
    with :ok <- Repository.Stairs.save(stairs) do
      stairs
    end
  end
end

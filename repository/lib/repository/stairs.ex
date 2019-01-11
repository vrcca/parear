defmodule Repository.Stairs do
  alias Repository.Parear.Stair

  def find_by_id(id) do
    Stair.find_by_id(id)
  end

  def save(stairs = %Parear.Stairs{}) do
    Stair.save_cascade(stairs)
    :ok
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

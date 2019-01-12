defimpl Parear.Repository, for: Parear.Stairs do
  def find_by_id(%Parear.Stairs{id: id}) do
    stairs = Repository.Parear.Stair.find_by_id(id)
    {:ok, stairs}
  end

  def save(stairs = %Parear.Stairs{}) do
    with {:ok, result} <- Repository.Parear.Stair.save_cascade(stairs) do
      stairs
    end
  end
end

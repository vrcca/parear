defmodule Repository.Parear.PairStatus do
  import Ecto.Changeset
  alias Repository.Parear.{Stair, Participant, PairStatus, Repo}
  use Repository.Parear.Schema

  @primary_key false
  schema "pair_statuses" do
    field(:total, :integer, default: 0)
    belongs_to(:stair, Stair, primary_key: true)
    belongs_to(:participant, Participant, primary_key: true)
    belongs_to(:friend, Participant, primary_key: true)
    timestamps()
  end

  def changeset(statuses = %PairStatus{}, params \\ %{}) do
    statuses
    |> cast(params, [:total])
    |> validate_required([:participant_id, :friend_id, :total])
  end

  def convert_all_from(%Parear.Stairs{statuses: statuses}) do
    Enum.reduce(statuses, [], fn {participant_id, matches}, acc ->
      friends =
        for {friend_id, total} <- matches do
          retrieve_or_create(participant_id, friend_id)
          |> changeset(%{total: total})
        end

      acc ++ friends
    end)
  end

  defp retrieve_or_create(id, another_id) do
    case find_by_id_pair(id, another_id) do
      nil -> %PairStatus{participant_id: id, friend_id: another_id}
      ps -> ps
    end
  end

  def find_by_id_pair(id, another_id) do
    filter = [participant_id: id, friend_id: another_id]
    Repo.get_by(PairStatus, filter)
  end
end

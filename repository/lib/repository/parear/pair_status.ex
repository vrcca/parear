defmodule Repository.Parear.PairStatus do
  import Ecto.Changeset
  alias Repository.Parear.{Stair, Participant, PairStatus}
  use Repository.Parear.Schema

  @primary_key false
  schema "pair_statuses" do
    field(:total, :integer, default: 0)
    belongs_to(:stair, Stair, primary_key: true)
    belongs_to(:participant, Participant, primary_key: true)
    belongs_to(:friend, Participant, primary_key: true)
    timestamps()
  end

  def changeset(statuses, params \\ %{}) do
    statuses
    |> cast(params, [:participant_id, :friend_id, :total])
    |> validate_required([:participant_id, :friend_id, :total])
  end

  def convert_all_from(%Parear.Stairs{statuses: statuses}) do
    Enum.reduce(statuses, [], fn {participant_id, matches}, acc ->
      friends =
        for {friend_id, total} <- matches do
          %PairStatus{}
          |> changeset(%{friend_id: friend_id, participant_id: participant_id, total: total})
        end

      acc ++ friends
    end)
  end
end

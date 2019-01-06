defmodule Repository.Parear.Stair do
  alias Repository.Parear.{Repo, Participant, PairStatus, Stair}
  use Repository.Parear.Schema
  import Ecto.Changeset

  schema "stairs" do
    field(:name, :string)
    field(:limit, :integer, default: 5)
    has_many(:participants, Participant)
    has_many(:pair_statuses, PairStatus)
    timestamps()
  end

  def changeset(stair, params \\ %{}) do
    stair
    |> cast(params, [:id, :name, :limit])
    |> validate_required([:name])
  end

  def all() do
    Stair
    |> Repo.all()
  end

  def save_all_from(stairs = %Parear.Stairs{}) do
    participants = Participant.convert_all_from(stairs)
    stair = changeset(%Stair{}, Map.from_struct(stairs))

    put_assoc(stair, :participants, participants)
    |> Repo.insert()
  end

  def load_participants(stairs = %Stair{}) do
    stairs
    |> Repo.preload(:participants)
  end
end

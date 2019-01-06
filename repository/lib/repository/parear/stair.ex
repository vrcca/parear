defmodule Repository.Parear.Stair do
  use Ecto.Schema
  import Ecto.Changeset
  alias Repository.Parear.{Repo, Participant, PairStatus, Stair}

  schema "stairs" do
    field(:name, :string)
    field(:limit, :integer, default: 5)
    has_many(:participants, Participant)
    has_many(:pair_statuses, PairStatus)
    timestamps()
  end

  def changeset(stair, params \\ %{}) do
    stair
    |> cast(params, [:name, :limit])
    |> validate_required([:name])
  end

  def all() do
    __MODULE__
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

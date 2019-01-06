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

  def find_by_id(id) do
    Repo.get(Stair, id)
  end

  def all() do
    Stair
    |> Repo.all()
  end

  def save_all_from(stairs = %Parear.Stairs{id: id}) do
    case find_by_id(id) do
      nil -> %Stair{}
      stair -> stair |> load_participants()
    end
    |> changeset(Map.from_struct(stairs))
    |> put_assoc(:participants, Participant.convert_all_from(stairs))
    |> Repo.insert_or_update()
  end

  def load_participants(stairs = %Stair{}) do
    stairs
    |> Repo.preload(:participants)
  end
end

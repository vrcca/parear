defmodule Repository.Parear.Stair do
  alias Repository.Parear.{Repo, Participant, PairStatus, Stair}
  use Repository.Parear.Schema
  import Ecto.Changeset

  schema "stairs" do
    field(:name, :string)
    field(:limit, :integer, default: 5)
    has_many(:participants, Participant, on_replace: :nilify)
    has_many(:pair_statuses, PairStatus, on_replace: :delete)
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

  def save_cascade(stairs = %Parear.Stairs{id: id}) do
    case find_by_id(id) do
      nil -> %Stair{}
      stair -> stair |> load_participants() |> load_pair_statuses()
    end
    |> changeset(Map.from_struct(stairs))
    |> put_assoc(:participants, Participant.convert_all_from(stairs))
    |> put_assoc(:pair_statuses, PairStatus.convert_all_from(stairs))
    |> Repo.insert_or_update()
  end

  def load_participants(stairs = %Stair{}) do
    stairs
    |> Repo.preload(:participants)
  end

  def load_pair_statuses(stairs = %Stair{}) do
    stairs
    |> Repo.preload(:pair_statuses)
  end
end

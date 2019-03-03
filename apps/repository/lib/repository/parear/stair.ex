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

  def insert_or_update_with_participants_changeset(stairs = %Parear.Stairs{id: id}) do
    retrieve_or_create(id)
    |> Repo.preload(:participants)
    |> changeset(Map.from_struct(stairs))
    |> put_assoc(:participants, Participant.convert_all_from(stairs))
  end

  def insert_or_update_with_statuses_changeset(stairs = %Parear.Stairs{id: id}) do
    retrieve_or_create(id)
    |> Repo.preload(:pair_statuses)
    |> changeset(Map.from_struct(stairs))
    |> put_assoc(:pair_statuses, PairStatus.convert_all_from(stairs))
  end

  def find_by_id(id) do
    Repo.get(Stair, id)
  end

  def find_by_name(name) do
    Repo.get_by(Stair, %{name: name})
  end

  def save_cascade(stairs = %Parear.Stairs{}) do
    {:ok, result} =
      Repo.transaction(fn ->
        Repo.insert_or_update(Stair.insert_or_update_with_participants_changeset(stairs))
        Repo.insert_or_update(Stair.insert_or_update_with_statuses_changeset(stairs))
      end)

    result
  end

  defp retrieve_or_create(id) do
    case find_by_id(id) do
      nil -> %Stair{}
      stair -> stair
    end
  end

  def load_pair_statuses(stairs) do
    stairs |> Repo.preload(:pair_statuses)
  end

  def load_participants(stairs) do
    stairs |> Repo.preload(:participants)
  end
end

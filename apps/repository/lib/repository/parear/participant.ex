defmodule Repository.Parear.Participant do
  import Ecto.Changeset
  alias Repository.Parear.{Stair, Participant, Repo}
  use Repository.Parear.Schema

  schema "participants" do
    field(:name, :string)
    belongs_to(:stair, Stair)
    timestamps()
  end

  def changeset(participant, params \\ %{}) do
    participant
    |> cast(params, [:id, :name, :stair_id])
    |> validate_required([:id, :name])
  end

  def convert_all_from(%Parear.Stairs{participants: participants}) do
    participants
    |> Enum.map(fn {id, participant} ->
      retrieve_or_create(id)
      |> changeset(Map.from_struct(participant))
    end)
  end

  defp retrieve_or_create(id) do
    case find_by_id(id) do
      nil -> %Participant{}
      p -> p
    end
  end

  def find_by_id(id) do
    Repo.get_by(Participant, %{id: id})
  end

  def insert(participant = %Parear.Participant{}, stairs_id) do
    %Participant{stair_id: stairs_id}
    |> changeset(Map.from_struct(participant))
    |> Repo.insert()
  end
end

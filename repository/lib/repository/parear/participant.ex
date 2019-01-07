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
    |> cast(params, [:name])
    |> validate_required([:name])
  end

  def convert_all_from(%Parear.Stairs{id: id, participants: participants}) do
    participants
    |> Enum.map(fn {name, _matches} ->
      retrieve_or_create(id, name)
      |> changeset(%{name: name})
    end)
  end

  defp retrieve_or_create(id, name) do
    case find_by_stair_id_and_name(id, name) do
      nil -> %Participant{name: name}
      p -> p
    end
  end

  defp find_by_stair_id_and_name(stair_id, name) do
    Repo.get_by(Participant, %{stair_id: stair_id, name: name})
  end
end

defmodule Repository.Parear.Participant do
  import Ecto.Changeset
  alias Repository.Parear.{Stair, Participant}
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

  def convert_all_from(%Parear.Stairs{participants: participants}) do
    participants
    |> Enum.map(&to_changeset/1)
  end

  defp to_changeset({name, _matches}) do
    changeset(%Participant{}, %{name: name})
  end
end

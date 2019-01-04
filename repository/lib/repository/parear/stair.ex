defmodule Repository.Parear.Stair do
  use Ecto.Schema

  alias Repository.Parear.Participant

  schema "stairs" do
    field :name, :string
    field :limit, :integer, default: 5
    has_many :participants, Participant
  end

  def changeset(stair, params \\ %{}) do
    stair
    |> Ecto.Changeset.cast(params, [:name, :limit])
    |> Ecto.Changeset.validate_required([:name])
  end
end

defmodule Repository.Parear.Stair do
  use Ecto.Schema
  import Ecto.Changeset
  alias Repository.Parear.{Participant, PairStatus}

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
end

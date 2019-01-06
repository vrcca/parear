defmodule Repository.Parear.PairStatus do
  use Ecto.Schema
  alias Repository.Parear.{Stair, Participant}

  schema "pair_statuses" do
    field(:total, :integer, default: 0)
    belongs_to(:stair, Stair)
    belongs_to(:participant, Participant)
    belongs_to(:friend, Participant)
    timestamps()
  end
end

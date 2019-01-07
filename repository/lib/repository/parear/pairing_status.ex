defmodule Repository.Parear.PairStatus do
  alias Repository.Parear.{Stair, Participant}
  use Repository.Parear.Schema

  @primary_key false
  schema "pair_statuses" do
    field(:total, :integer, default: 0)
    belongs_to(:stair, Stair, primary_key: true)
    belongs_to(:participant, Participant, primary_key: true)
    belongs_to(:friend, Participant, primary_key: true)
    timestamps()
  end

  def convert_all_from(stairs = %Parear.Stairs{}) do
    []
  end
end

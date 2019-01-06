defmodule Repository.Parear.Participant do
  use Ecto.Schema

  alias Repository.Parear.Stair

  schema "participants" do
    field(:name, :string)
    belongs_to(:stair, Stair)
    timestamps()
  end
end

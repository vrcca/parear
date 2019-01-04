defmodule Repository.Parear.Participant do
  use Ecto.Schema

  alias Repository.Parear.Stair

  schema "participants" do
    field :name
    has_one :stair, Stair
  end
end

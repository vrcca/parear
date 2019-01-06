defmodule Repository.Parear.ParticipantTest do
  use ExUnit.Case

  alias Repository.Parear.Participant

  test "converts from Stairs to list of participants" do
    stairs =
      with pair_stairs <- Parear.Stairs.new("Whiskey with participants", limit: 10),
           updated_stairs <- Parear.Stairs.add_participant(pair_stairs, "Vitor") do
        Parear.Stairs.add_participant(updated_stairs, "Kenya")
      end

    participants = Participant.convert_all_from(stairs)

    assert 2 == length(participants)

    assert Enum.any?(participants, fn changeset ->
             Ecto.Changeset.get_field(changeset, :name) == "Vitor"
           end)

    assert Enum.any?(participants, fn changeset ->
             Ecto.Changeset.get_field(changeset, :name) == "Kenya"
           end)
  end
end

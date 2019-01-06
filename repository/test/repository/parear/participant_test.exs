defmodule Repository.Parear.ParticipantTest do
  use ExUnit.Case

  alias Repository.Parear.Participant

  test "Converts from Stairs to list of participants" do
    stairs =
      with pair_stairs <- Parear.Stairs.new("Whiskey with participants", limit: 10),
           updated_stairs <- Parear.Stairs.add_participant(pair_stairs, "Vitor") do
        Parear.Stairs.add_participant(updated_stairs, "Kenya")
      end

    participants = Participant.convert_all_from(stairs)

    assert 2 == length(participants)
    assert participants |> has_participant_named?("Vitor")
    assert participants |> has_participant_named?("Kenya")
  end

  @tag :pending
  test "Converts from Stairs to list of previously saved participants" do
  end

  defp has_participant_named?(participants, name) do
    Enum.any?(participants, fn changeset ->
      Ecto.Changeset.get_field(changeset, :name) == name
    end)
  end
end

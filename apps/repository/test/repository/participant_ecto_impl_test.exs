defmodule Repository.ParticipantEctoImplTest do
  alias Repository.Parear.Repo

  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

    stairs =
      Parear.Stairs.new("Simple Stairs")
      |> Parear.Repository.save()

    %{stairs: stairs}
  end

  test "Should insert and find new participant", %{stairs: stairs} do
    new_participant = Parear.Participant.new("Vitor")
    assert {:none} == find_by_id(new_participant)

    {:ok, _} = Parear.ParticipantRepository.insert(new_participant, stairs)

    assert {:ok, new_participant} = find_by_id(new_participant)
  end

  defp find_by_id(participant_with_id = %Parear.Participant{}) do
    Parear.ParticipantRepository.find_by_id(participant_with_id)
  end
end

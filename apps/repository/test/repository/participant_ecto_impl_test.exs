defmodule Repository.ParticipantEctoImplTest do
  alias Repository.Parear.Repo
  alias Parear.{Stairs, Participant}

  use ExUnit.Case, async: true

  @stairs_repository Repository.ParearEctoRepository
  @repository Parear.ParticipantRepository

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

    stairs =
      Stairs.new("Simple Stairs")
      |> @stairs_repository.save()

    %{stairs: stairs}
  end

  test "Should insert and find new participant", %{stairs: stairs} do
    new_participant = Participant.new("Vitor")
    assert {:none} == find_by_id(new_participant)

    {:ok, _} = @repository.insert(new_participant, stairs)

    assert {:ok, new_participant} = find_by_id(new_participant)
  end

  defp find_by_id(participant_with_id = %Participant{}) do
    @repository.find_by_id(participant_with_id)
  end
end

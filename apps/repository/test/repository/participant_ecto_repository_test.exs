defmodule Repository.ParticipantEctoRepositoryTest do
  alias Repository.Parear.Repo
  alias Parear.{Stairs, Participant}

  use ExUnit.Case, async: true

  @stairs_repository Repository.ParearEctoRepository
  @repository Repository.ParticipantEctoRepository

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

    stairs =
      Stairs.new("Simple Stairs")
      |> @stairs_repository.save()

    %{stairs_id: stairs.id}
  end

  test "Should insert and find new participant", %{stairs_id: stairs_id} do
    new_participant = Participant.new("Vitor")
    assert {:none} == find_by_id(new_participant)

    {:ok, _} = @repository.insert(new_participant, stairs_id)

    assert {:ok, new_participant} = find_by_id(new_participant)
  end

  test "Should update participant", %{stairs_id: stairs_id} do
    participant = Participant.new("Vitor")
    {:ok, _} = @repository.insert(participant, stairs_id)
    participant = Participant.update_name(participant, "Vitor's New Name")

    {:ok, _} = @repository.update(participant)

    assert participant = find_by_id(participant)
  end

  defp find_by_id(%Participant{id: id}) do
    @repository.find_by_id(id)
  end
end

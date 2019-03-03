defmodule Repository.Parear.ParticipantTest do
  use ExUnit.Case

  import Ecto.Changeset
  alias Repository.Parear.{Participant, Stair, Repo}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

    stairs =
      with pair_stairs <- Parear.Stairs.new("Whiskey with participants", limit: 10),
           updated_stairs <- Parear.Stairs.add_participant(pair_stairs, "Vitor") do
        Parear.Stairs.add_participant(updated_stairs, "Kenya")
      end

    %{pair_stairs: stairs}
  end

  test "Converts to list of new participants", %{pair_stairs: stairs} do
    participants = Participant.convert_all_from(stairs)

    assert 2 == length(participants)
    assert participants |> has_participant_named?("Vitor")
    assert true == participants |> has_id?("Vitor")
    assert participants |> has_participant_named?("Kenya")
    assert true == participants |> has_id?("Kenya")
  end

  test "Converts to list of previously saved participants", %{
    pair_stairs: stairs_with_participants
  } do
    {:ok, saved_stair} = Stair.save_cascade(stairs_with_participants)
    participants = Participant.convert_all_from(stairs_with_participants)

    assert 2 == length(participants)
    assert participants |> has_participant_named?("Vitor")
    assert participants |> has_id?("Vitor")

    assert saved_stair |> Repo.preload(:participants) |> has_same_id_in(participants, "Vitor")
    assert participants |> has_participant_named?("Kenya")
    assert participants |> has_id?("Kenya")
    assert saved_stair |> Repo.preload(:participants) |> has_same_id_in(participants, "Kenya")
  end

  defp has_same_id_in(saved_stair, participants, name) do
    id_from_stair = saved_stair |> Map.get(:participants) |> get_id(name)
    id_from_participants = participants |> get_id(name)
    assert id_from_stair == id_from_participants
  end

  defp has_participant_named?(participants, name) do
    Enum.any?(participants, fn changeset ->
      get_field(changeset, :name) == name
    end)
  end

  defp has_id?(participants, name) do
    get_id(participants, name) != nil
  end

  defp get_id(participants, name) when is_list(participants) do
    Enum.find(participants, fn p ->
      get_id(p) != nil && get_name(p) == name
    end)
    |> get_id()
  end

  defp get_name(p = %Participant{}) do
    Map.get(p, :name)
  end

  defp get_name(p) do
    get_field(p, :name)
  end

  defp get_id(nil), do: nil
  defp get_id(p = %Participant{}), do: Map.get(p, :id)
  defp get_id(p), do: get_field(p, :id)
end

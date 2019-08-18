defmodule Repository.Parear.PairStatusTest do
  import Ecto.Changeset
  alias Repository.Parear.{PairStatus, Repo}
  alias Parear.Stairs
  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    %{pair_stairs: Parear.Stairs.new("Another Whiskey", limit: 10)}
  end

  test "Returns empty when there are no participants", %{pair_stairs: stairs} do
    pair_statuses = PairStatus.convert_all_from(stairs)
    assert Enum.empty?(pair_statuses)
  end

  test "Returns matching pairs with participants with zeroes", %{pair_stairs: stairs} do
    stairs =
      stairs
      |> Stairs.add_participant("Vitor")
      |> Stairs.add_participant("Kenya")

    vitor = find_by_name(stairs, "Vitor")
    kenya = find_by_name(stairs, "Kenya")

    pair_statuses = PairStatus.convert_all_from(stairs)
    assert pair_statuses |> length() == 2
    assert pair_statuses |> has_matching_status?(vitor.id, kenya.id, 0)
    assert pair_statuses |> has_matching_status?(kenya.id, vitor.id, 0)
  end

  defp has_matching_status?(statuses, participant_id, another_id, total) do
    matches =
      statuses
      |> Enum.find(fn status ->
        get_field(status, :participant_id) == participant_id &&
          get_field(status, :friend_id) == another_id
      end)

    matches != nil && get_field(matches, :total) == total
  end

  defp find_by_name(%Stairs{participants: participants}, name) do
    participants
    |> Enum.into([])
    |> Enum.map(fn {_id, p} -> p end)
    |> Enum.find(fn p -> p.name == name end)
  end
end

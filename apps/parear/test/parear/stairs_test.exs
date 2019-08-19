defmodule Parear.StairsTest do
  use ExUnit.Case
  doctest Parear.Stairs
  alias Parear.{Stairs, Participant}

  setup do
    %{simple_stairs: stairs_with_two_participants()}
  end

  test "Creates a new stairs with id and name" do
    stairs = Stairs.new("Whiskey")
    assert stairs.name == "Whiskey"
    assert stairs.id != nil
  end

  test "Adds participant with id and name" do
    participant =
      Stairs.new("Another")
      |> Stairs.add_participant("Vitor")
      |> find_by_name("Vitor")

    assert nil != participant
    assert nil != participant.id
    assert "Vitor" == participant.name
  end

  test "Adding only one participant has no pair status" do
    stairs =
      Stairs.new("Another")
      |> Stairs.add_participant("Vitor")

    vitor = find_by_name(stairs, "Vitor")

    statuses =
      stairs
      |> Stairs.statuses_for_participant(vitor)

    assert nil == statuses
  end

  test "Adding a second participant automatically matches with everybody else", %{
    simple_stairs: stairs
  } do
    assert map_size(stairs.participants) == 2

    vitor = stairs |> find_by_name("Vitor")
    kenya = stairs |> find_by_name("Kenya")

    assert %{vitor.id => %{kenya.id => 0}, kenya.id => %{vitor.id => 0}} == stairs.statuses
  end

  test "Pairing two participants automatically updates their pair count", %{simple_stairs: stairs} do
    vitor = stairs |> find_by_name("Vitor")
    kenya = stairs |> find_by_name("Kenya")

    {:ok, stairs} =
      stairs
      |> Stairs.add_participant("Elvis")
      |> Stairs.pair(vitor, kenya)

    elvis = stairs |> find_by_name("Elvis")

    assert %{kenya.id => 1, elvis.id => 0} == stairs |> Stairs.statuses_for_participant(vitor)
    assert %{vitor.id => 1, elvis.id => 0} == stairs |> Stairs.statuses_for_participant(kenya)
    assert %{vitor.id => 0, kenya.id => 0} == stairs |> Stairs.statuses_for_participant(elvis)
  end

  test "Undo pairing two participants automatically undos their pair count", %{
    simple_stairs: stairs
  } do
    stairs = stairs |> Stairs.add_participant("Elvis")
    vitor = stairs |> find_by_name("Vitor")
    kenya = stairs |> find_by_name("Kenya")
    elvis = stairs |> find_by_name("Elvis")

    stairs =
      with {:ok, paired_stairs} <- Stairs.pair(stairs, vitor, kenya),
           {:ok, unpaired_stairs} <- Stairs.unpair(paired_stairs, vitor, kenya) do
        unpaired_stairs
      end

    assert %{kenya.id => 0, elvis.id => 0} == stairs |> Stairs.statuses_for_participant(vitor)
    assert %{vitor.id => 0, elvis.id => 0} == stairs |> Stairs.statuses_for_participant(kenya)
    assert %{vitor.id => 0, kenya.id => 0} == stairs |> Stairs.statuses_for_participant(elvis)
  end

  test "Should do nothing when unpairing when they never paired", %{simple_stairs: stairs} do
    vitor = stairs |> find_by_name("Vitor")
    kenya = stairs |> find_by_name("Kenya")
    {:ok, stairs} = Stairs.unpair(stairs, vitor, kenya)

    assert %{kenya.id => 0} == stairs |> Stairs.statuses_for_participant(vitor)
    assert %{vitor.id => 0} == stairs |> Stairs.statuses_for_participant(kenya)
  end

  test "Should be able to reset stairs", %{simple_stairs: stairs} do
    vitor = stairs |> find_by_name("Vitor")
    kenya = stairs |> find_by_name("Kenya")

    stairs =
      with {:ok, paired_stairs} = Stairs.pair(stairs, vitor, kenya) do
        Stairs.reset_all_counters(paired_stairs)
      end

    assert %{kenya.id => 0} == stairs |> Stairs.statuses_for_participant(vitor)
    assert %{vitor.id => 0} == stairs |> Stairs.statuses_for_participant(kenya)
  end

  test "Should allow removing a participant", %{simple_stairs: stairs} do
    vitor = find_by_name(stairs, "Vitor")

    stairs =
      stairs
      |> Stairs.add_participant("Elvis")
      |> Stairs.remove_participant(vitor)

    vitor = find_by_name(stairs, "Vitor")
    elvis = find_by_name(stairs, "Elvis")
    kenya = find_by_name(stairs, "Kenya")

    assert nil == vitor
    assert %{elvis.id => 0} == stairs |> Stairs.statuses_for_participant(kenya)
    assert %{kenya.id => 0} == stairs |> Stairs.statuses_for_participant(elvis)
  end

  test "Should delete statuses from removed participant", %{simple_stairs: stairs} do
    vitor = stairs |> find_by_name("Vitor")
    stairs = stairs |> Stairs.remove_participant(vitor)
    assert nil == stairs |> Stairs.statuses_for_participant(vitor)
  end

  test "Should clean up single participant statuses", %{simple_stairs: stairs} do
    vitor = stairs |> find_by_name("Vitor")
    stairs = stairs |> Stairs.remove_participant(vitor)
    kenya = stairs |> find_by_name("Kenya")
    assert nil == stairs |> Stairs.statuses_for_participant(kenya)
  end

  test "Should limit maximum of pairing between participants" do
    stairs =
      Stairs.new("Limited Stairs", limit: 2)
      |> Stairs.add_participant("Elvis")
      |> Stairs.add_participant("Vitor")

    vitor = find_by_name(stairs, "Vitor")
    elvis = find_by_name(stairs, "Elvis")

    {:error, msg} =
      with {:ok, updated_stairs} <- Stairs.pair(stairs, elvis, vitor),
           {:ok, stairs_on_limit} <- Stairs.pair(updated_stairs, elvis, vitor) do
        Stairs.pair(stairs_on_limit, elvis, vitor)
      end

    assert msg == "maximum_limit_reached"
  end

  test "Should result error when pairing unknown participants", %{simple_stairs: stairs} do
    not_registered = Participant.new("Notregistered")
    kenya = find_by_name(stairs, "Kenya")

    {:error, msg} =
      stairs
      |> Stairs.pair(not_registered, kenya)

    assert msg == "unknown_participant"
  end

  test "Should result error when unpairing unknown participants" do
    stairs = stairs_with_two_participants()
    kenya = find_by_name(stairs, "Kenya")
    unknown_participant = Participant.new("Another one")

    {:error, msg} =
      stairs
      |> Stairs.unpair(unknown_participant, kenya)

    assert msg == "unknown_participant"
  end

  test "Should not create empty statuses for single participant in stairs" do
    stairs =
      Stairs.new("Single Participant Stairs")
      |> Stairs.add_participant("Vitor")

    assert %{} == stairs.statuses
  end

  test "Should assume total 0 when there is no statuses" do
    vitor = Participant.new("Vitor")
    kenya = Participant.new("Kenya")

    stairs = %Stairs{
      id: "abc",
      name: "Whiskey",
      participants: %{
        vitor.id => vitor,
        kenya.id => kenya
      },
      statuses: %{}
    }

    {:ok, updated_stairs} = stairs |> Stairs.pair(vitor, kenya)

    assert updated_stairs.statuses == %{
             vitor.id => %{kenya.id => 1},
             kenya.id => %{vitor.id => 1}
           }
  end

  test "Should update participant", %{simple_stairs: stairs} do
    participant =
      stairs
      |> find_by_name("Vitor")
      |> Participant.update_name("New Name")

    stairs = Stairs.update_participant(stairs, participant)
    updated_participant = find_by_name(stairs, "New Name")
    previous_participant = find_by_name(stairs, "Vitor")

    assert nil == previous_participant
    assert participant == updated_participant
  end

  defp stairs_with_two_participants() do
    Stairs.new("Old Stairs")
    |> Stairs.add_participant("Vitor")
    |> Stairs.add_participant("Kenya")
  end

  defp find_by_name(%Stairs{participants: participants}, name) do
    participants
    |> Enum.into([])
    |> Enum.map(fn {_id, p} -> p end)
    |> Enum.find(fn p -> p.name == name end)
  end
end

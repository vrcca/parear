defmodule Parear.StairsTest do
  use ExUnit.Case
  doctest Parear.Stairs
  alias Parear.Stairs

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
      |> Stairs.find_participant_by_name("Vitor")

    assert nil != participant
    assert nil != participant.id
    assert "Vitor" == participant.name
  end

  test "Adding only one participant has no pair status" do
    stairs =
      Stairs.new("Another")
      |> Stairs.add_participant("Vitor")

    participant = Stairs.find_participant_by_name(stairs, "Vitor")

    statuses =
      stairs
      |> Stairs.statuses_for_participant(participant)

    assert nil == statuses
  end

  test "Adding a second participant automatically matches with everybody else", %{
    simple_stairs: stairs
  } do
    assert map_size(stairs.participants) == 2

    vitor = stairs |> Stairs.find_participant_by_name("Vitor")
    kenya = stairs |> Stairs.find_participant_by_name("Kenya")

    assert %{vitor.id => %{kenya.id => 0}, kenya.id => %{vitor.id => 0}} == stairs.statuses
  end

  test "Pairing two participants automatically updates their pair count", %{simple_stairs: stairs} do
    {:ok, stairs} =
      stairs
      |> Stairs.add_participant("Elvis")
      |> Stairs.pair("Vitor", "Kenya")

    vitor = stairs |> Stairs.find_participant_by_name("Vitor")
    kenya = stairs |> Stairs.find_participant_by_name("Kenya")
    elvis = stairs |> Stairs.find_participant_by_name("Elvis")

    assert %{kenya.id => 1, elvis.id => 0} == stairs |> Stairs.statuses_for_participant(vitor)
    assert %{vitor.id => 1, elvis.id => 0} == stairs |> Stairs.statuses_for_participant(kenya)
    assert %{vitor.id => 0, kenya.id => 0} == stairs |> Stairs.statuses_for_participant(elvis)
  end

  test "Undo pairing two participants automatically undos their pair count", %{
    simple_stairs: stairs
  } do
    stairs = stairs |> Stairs.add_participant("Elvis")

    stairs =
      with {:ok, paired_stairs} <- Stairs.pair(stairs, "Vitor", "Kenya"),
           {:ok, unpaired_stairs} <- Stairs.unpair(paired_stairs, "Vitor", "Kenya") do
        unpaired_stairs
      end

    vitor = stairs |> Stairs.find_participant_by_name("Vitor")
    kenya = stairs |> Stairs.find_participant_by_name("Kenya")
    elvis = stairs |> Stairs.find_participant_by_name("Elvis")

    assert %{kenya.id => 0, elvis.id => 0} == stairs |> Stairs.statuses_for_participant(vitor)
    assert %{vitor.id => 0, elvis.id => 0} == stairs |> Stairs.statuses_for_participant(kenya)
    assert %{vitor.id => 0, kenya.id => 0} == stairs |> Stairs.statuses_for_participant(elvis)
  end

  test "Should do nothing when unpairing when they never paired", %{simple_stairs: stairs} do
    {:ok, stairs} = Stairs.unpair(stairs, "Vitor", "Kenya")

    vitor = stairs |> Stairs.find_participant_by_name("Vitor")
    kenya = stairs |> Stairs.find_participant_by_name("Kenya")
    assert %{kenya.id => 0} == stairs |> Stairs.statuses_for_participant(vitor)
    assert %{vitor.id => 0} == stairs |> Stairs.statuses_for_participant(kenya)
  end

  test "Should be able to reset stairs", %{simple_stairs: stairs} do
    stairs =
      with {:ok, paired_stairs} = Stairs.pair(stairs, "Vitor", "Kenya") do
        Stairs.reset_all_counters(paired_stairs)
      end

    vitor = stairs |> Stairs.find_participant_by_name("Vitor")
    kenya = stairs |> Stairs.find_participant_by_name("Kenya")
    assert %{kenya.id => 0} == stairs |> Stairs.statuses_for_participant(vitor)
    assert %{vitor.id => 0} == stairs |> Stairs.statuses_for_participant(kenya)
  end

  test "Should allow removing a participant", %{simple_stairs: stairs} do
    stairs =
      stairs
      |> Stairs.add_participant("Elvis")
      |> Stairs.remove_participant("Vitor")

    vitor = stairs |> Stairs.find_participant_by_name("Vitor")
    elvis = stairs |> Stairs.find_participant_by_name("Elvis")
    kenya = stairs |> Stairs.find_participant_by_name("Kenya")

    assert nil == vitor
    assert %{elvis.id => 0} == stairs |> Stairs.statuses_for_participant(kenya)
    assert %{kenya.id => 0} == stairs |> Stairs.statuses_for_participant(elvis)
  end

  test "Should delete statuses from removed participant", %{simple_stairs: stairs} do
    vitor = stairs |> Stairs.find_participant_by_name("Vitor")
    stairs = stairs |> Stairs.remove_participant(vitor)
    assert nil == stairs |> Stairs.statuses_for_participant(vitor)
  end

  test "Should clean up single participant statuses", %{simple_stairs: stairs} do
    stairs = stairs |> Stairs.remove_participant("Vitor")
    kenya = stairs |> Stairs.find_participant_by_name("Kenya")
    assert nil == stairs |> Stairs.statuses_for_participant(kenya)
  end

  test "Should limit maximum of pairing between participants" do
    stairs =
      Stairs.new("Limited Stairs", limit: 2)
      |> Stairs.add_participant("Elvis")
      |> Stairs.add_participant("Vitor")

    {:error, msg} =
      with {:ok, updated_stairs} <- Stairs.pair(stairs, "Elvis", "Vitor"),
           {:ok, stairs_on_limit} <- Stairs.pair(updated_stairs, "Elvis", "Vitor") do
        Stairs.pair(stairs_on_limit, "Elvis", "Vitor")
      end

    assert msg == "maximum_limit_reached"
  end

  test "Should result error when pairing unknown participants", %{simple_stairs: stairs} do
    {:error, msg} =
      stairs
      |> Stairs.pair("Notregistered", "Kenya")

    assert msg == "unknown_participant"
  end

  test "Should result error when unpairing unknown participants" do
    {:error, msg} =
      stairs_with_two_participants()
      |> Stairs.unpair("Notregistered", "Kenya")

    assert msg == "unknown_participant"
  end

  test "Should not create empty statuses for single participant in stairs" do
    stairs =
      Stairs.new("Single Participant Stairs")
      |> Stairs.add_participant("Vitor")

    assert %{} == stairs.statuses
  end

  defp stairs_with_two_participants() do
    Stairs.new("Old Stairs")
    |> Stairs.add_participant("Vitor")
    |> Stairs.add_participant("Kenya")
  end
end

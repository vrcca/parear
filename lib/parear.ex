defmodule Parear do

  alias Parear.Stairs

  defdelegate create_stairs(name), to: Stairs

  defdelegate add_person(stairs, name), to: Stairs

  defdelegate pair(stairs, person, another_person), to: Stairs

  defdelegate unpair(stairs, person, another_person), to: Stairs

  defdelegate reset_all_counts(stairs), to: Stairs

  defdelegate remove_person(stairs, name), to: Stairs

end

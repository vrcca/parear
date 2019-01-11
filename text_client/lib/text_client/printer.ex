defmodule TextClient.Printer do
  def from(%Parear.Stairs{id: id, participants: participants, statuses: matrix}) do
    matrix =
      matrix
      |> convert_ids_to_participants(participants)

    "Stairs of id #{id}\n" <> from(%{stairs: matrix})
  end

  def from(%{stairs: matrix}) do
    participants = Map.keys(matrix)
    print_row(0, participants, [], matrix, "")
  end

  defp print_row(_, [], matches, _, acc) do
    {_last, rest} = List.pop_at(matches, -1)
    acc <> "|\t\t|\t" <> Enum.join(rest, "\t|\t") <> "\t|"
  end

  defp print_row(0, [participant | rest], [], matrix, acc) do
    acc <> print_row(1, rest, [participant], matrix, acc)
  end

  defp print_row(columns, [participant | rest], matches, matrix, acc) do
    row =
      Enum.reduce(matches, "|\t#{participant}\t|\t", fn friend, col ->
        total = matrix[participant][friend]
        col <> "#{total}\t|\t"
      end)

    acc <> row <> "\n" <> print_row(columns + 1, rest, matches ++ [participant], matrix, acc)
  end

  defp convert_ids_to_participants(matrix, participants) do
    matrix
    |> Enum.reduce(%{}, fn {id, friends}, acc ->
      matches =
        friends
        |> Enum.reduce(%{}, fn {friend_id, total}, acc ->
          Map.put(acc, participants[friend_id], total)
        end)

      Map.put(acc, participants[id], matches)
    end)
  end
end

defimpl String.Chars, for: Parear.Participant do
  def to_string(%Parear.Participant{name: name}) do
    name
  end
end

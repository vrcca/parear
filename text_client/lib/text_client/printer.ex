defmodule TextClient.StairsView do
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
end

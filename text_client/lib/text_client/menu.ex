defmodule TextClient.Menu do
  def options() do
    options =
      [
        "/list",
        "/add \"name\"",
        "/remove \"name\"",
        "/pair \"name\" \"another name\"",
        "/unpair \"name\" \"another name\"",
        "/unpair \"name\" \"another name\"",
        "/reset_all_counters CONFIRM_RESET",
        "/quit"
      ]
      |> Enum.join("\n\t")

    "Options:\n\t" <> options
  end

  def query_name() do
    IO.gets("What is the name of the pair matrix?\n ")
    |> check_name()
  end

  defp check_name({:error, reason}) do
    IO.puts("Program ended: #{reason}")
    exit(:normal)
  end

  defp check_name(:eof) do
    IO.puts("Sorry to see you go...")
    exit(:normal)
  end

  defp check_name(input) do
    input = String.trim(input)

    cond do
      input =~ ~r/[a-zA-Z0-9]/ ->
        input

      true ->
        IO.puts("Please, enter a valid name (letters and numbers only)")
        query_name()
    end
  end
end

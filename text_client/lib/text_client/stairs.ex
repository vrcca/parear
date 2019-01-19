defmodule TextClient.Stairs do
  alias TextClient.Printer

  def accept_option(stairs, args) do
    String.split(args)
    |> execute_option(stairs)
  end

  defp execute_option(["/list"], stairs) do
    Parear.list(stairs)
    |> on_result("Stairs retrieved.")
  end

  defp execute_option(["/add" | names], stairs) when is_pid(stairs) do
    {:ok, %Parear.Stairs{id: id}} = Parear.list(stairs)

    Enum.each(names, fn name ->
      name = sanitize_name(name)
      Parear.add_participant(id, name)
    end)

    added_names = Enum.join(names, ", ")

    Parear.list(id)
    |> on_result("#{added_names} added to the pair stairs.")
  end

  defp execute_option(["/remove" | names], stairs) do
    Enum.each(names, fn name ->
      name = sanitize_name(name)
      Parear.remove_participant(stairs, name)
    end)

    removed_names = Enum.join(names, ", ")

    Parear.list(stairs)
    |> on_result("#{removed_names} removed from the pair stairs.")
  end

  defp execute_option(["/pair", name, another_name], stairs) do
    update_pair_count_with(&Parear.pair(stairs, &1, &2), name, another_name)
  end

  defp execute_option(["/unpair", name, another_name], stairs) do
    update_pair_count_with(&Parear.unpair(stairs, &1, &2), name, another_name)
  end

  defp execute_option(["/reset_all_counters", "CONFIRM_RESET"], stairs) do
    Parear.reset_all_counters(stairs)
    |> on_result("All counters were reseted.")
  end

  defp execute_option(["/quit"], _stairs) do
    IO.puts("Sorry to see you go!")
    exit(:normal)
  end

  defp execute_option(option, _stairs), do: "\nUnknown command: #{option}\n"

  defp update_pair_count_with(fun, name, another_name) do
    name = sanitize_name(name)
    another_name = sanitize_name(another_name)

    fun.(name, another_name)
    |> on_result("Stairs updated.")
  end

  defp on_result({:ok, matrix}, title) do
    [
      "",
      "#{title}\n",
      "Current stairs:",
      Printer.from(matrix),
      ""
    ]
    |> Enum.join("\n")
  end

  defp on_result({:error, reason}, _title) do
    [
      "",
      "Error!\n",
      "#{reason}",
      ""
    ]
    |> Enum.join("\n")
  end

  defp sanitize_name(name), do: String.replace(name, ~r/\"/, "")
end

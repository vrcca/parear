defmodule TextClient.Interact do
  alias TextClient.Menu
  alias TextClient.Stairs

  def start() do
    Menu.query_name()
    |> new_stairs()
    |> run()
  end

  defp new_stairs(name) do
    Parear.reload_by_name(name)
    |> create_if_not_found(name)
  end

  defp create_if_not_found({:error, %{reason: :stairs_could_not_be_found}}, name),
    do: Parear.new_stairs(name)

  defp create_if_not_found(stairs, _name) do
    stairs
  end

  defp run(stairs) do
    Menu.options()
    |> IO.puts()

    command = IO.gets("Type command: ")

    Stairs.accept_option(stairs, command)
    |> IO.puts()

    run(stairs)
  end
end

defmodule TextClient.Interact do
  alias TextClient.Menu
  alias TextClient.Stairs

  def start() do
    Menu.query_name()
    |> new_stairs()
    |> run()
  end

  defp new_stairs(name) do
    Parear.new_stairs(name)
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

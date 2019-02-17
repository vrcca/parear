defmodule PairStairsWeb.StairsChannel do
  use Phoenix.Channel

  alias Parear.Stairs

  def join("stairs:" <> id, _message, socket) do
    socket = assign(socket, :stairs_id, id)
    {:ok, socket}
  end

  def handle_in("stairs", _, socket) do
    id = socket.assigns[:stairs_id]
    {:ok, stairs} = Parear.list(id)
    push(socket, "stairs", convert_to_map(stairs))
    {:noreply, socket}
  end

  defp convert_to_map(%Stairs{id: id, participants: participants, statuses: statuses}) do
    %{id: id, participants: convert_to_map(participants), statuses: statuses}
  end

  defp convert_to_map(participants = %{}) do
    Enum.reduce(participants, %{}, fn {id, p}, acc ->
      Map.put(acc, id, Map.from_struct(p))
    end)
  end
end

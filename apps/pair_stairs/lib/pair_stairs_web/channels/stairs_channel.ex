defmodule PairStairsWeb.StairsChannel do
  use Phoenix.Channel

  alias PairStairsWeb.StairsView
  alias Parear.Participant

  def join("stairs:" <> id, _message, socket) do
    socket = assign(socket, :stairs_id, id)
    {:ok, socket}
  end

  def handle_in("stairs", _, socket) do
    id = socket.assigns[:stairs_id]
    {:ok, stairs} = Parear.list(id)
    push(socket, "stairs", StairsView.convert_to_map(stairs))
    {:noreply, socket}
  end

  def handle_in("pair", %{"participant" => participant, "friend" => friend}, socket) do
    id = socket.assigns[:stairs_id]
    participant = Participant.new(participant["name"], id: participant["id"])
    friend = Participant.new(friend["name"], id: friend["id"])
    Parear.pair(id, participant, friend)
    {:ok, stairs} = Parear.list(id)
    broadcast!(socket, "stairs", StairsView.convert_to_map(stairs))
    {:noreply, socket}
  end

  def handle_in("unpair", %{"participant" => participant, "friend" => friend}, socket) do
    id = socket.assigns[:stairs_id]
    participant = Participant.new(participant["name"], id: participant["id"])
    friend = Participant.new(friend["name"], id: friend["id"])
    Parear.unpair(id, participant, friend)
    {:ok, stairs} = Parear.list(id)
    broadcast!(socket, "stairs", StairsView.convert_to_map(stairs))
    {:noreply, socket}
  end
end

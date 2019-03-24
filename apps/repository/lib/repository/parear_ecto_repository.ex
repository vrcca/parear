defmodule Repository.ParearEctoRepository do
  alias Repository.Parear.Stair

  @behaviour Parear.Repository

  @impl Parear.Repository
  def find_by_id(%Parear.Stairs{id: id}) do
    Stair.find_by_id(id)
    |> respond_to_find()
  end

  @impl Parear.Repository
  def find_by_name(%Parear.Stairs{name: name}) do
    Stair.find_by_name(name)
    |> respond_to_find()
  end

  @impl Parear.Repository
  def save(stairs = %Parear.Stairs{}) do
    with {:ok, _result} <- Stair.save_cascade(stairs) do
      stairs
    end
  end

  defp respond_to_find(nil), do: {:none}

  defp respond_to_find(stairs) do
    stairs =
      stairs
      |> Stair.load_participants()
      |> Stair.load_pair_statuses()
      |> to_domain()

    {:ok, stairs}
  end

  defp to_domain(response = %Stair{}) do
    %Parear.Stairs{
      id: response.id,
      name: response.name,
      limit: response.limit,
      participants: to_participants_domain(response.participants),
      statuses: to_statuses_domain(response.pair_statuses)
    }
  end

  defp to_domain(%Repository.Parear.Participant{id: id, name: name}) do
    %Parear.Participant{id: id, name: name}
  end

  defp to_participants_domain(participants) when is_list(participants) do
    participants
    |> Enum.reduce(%{}, fn participant, domain ->
      Map.put(domain, participant.id, to_domain(participant))
    end)
  end

  defp to_statuses_domain(statuses) when is_list(statuses) do
    statuses
    |> Enum.reduce(%{}, fn status, domain ->
      matches =
        Map.get(domain, status.participant_id, %{})
        |> Map.put(status.friend_id, status.total)

      Map.put(domain, status.participant_id, matches)
    end)
  end
end

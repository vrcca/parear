defmodule Repository.ParticipantEctoRepository do
  @behaviour Parear.ParticipantRepository

  @impl Parear.ParticipantRepository
  def insert(participant = %Parear.Participant{}, stairs_id) do
    Repository.Parear.Participant.insert(participant, stairs_id)
  end

  @impl Parear.ParticipantRepository
  def update(participant = %Parear.Participant{}) do
    Repository.Parear.Participant.update(participant)
  end

  @impl Parear.ParticipantRepository
  def find_by_id(id) do
    Repository.Parear.Participant.find_by_id(id)
    |> handle_result()
  end

  defp handle_result(nil), do: {:none}

  defp handle_result(participant) do
    to_domain(participant)
  end

  defp to_domain(%Repository.Parear.Participant{id: id, name: name}) do
    {:ok, %Parear.Participant{id: id, name: name}}
  end
end

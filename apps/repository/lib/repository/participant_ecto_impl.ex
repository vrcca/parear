defmodule Repository.ParticipantEctoImpl do
  defimpl Parear.ParticipantRepository, for: Parear.Participant do
    def insert(participant = %Parear.Participant{}, stairs = %Parear.Stairs{}) do
      Repository.Parear.Participant.insert(participant, stairs)
    end

    def find_by_id(%Parear.Participant{id: id}) do
      Repository.Parear.Participant.find_by_id(id)
      |> Repository.ParticipantEctoImpl.handle_result()
    end
  end

  def handle_result(nil), do: {:none}

  def handle_result(participant) do
    to_domain(participant)
  end

  def to_domain(%Repository.Parear.Participant{id: id, name: name}) do
    {:ok, %Parear.Participant{id: id, name: name}}
  end
end

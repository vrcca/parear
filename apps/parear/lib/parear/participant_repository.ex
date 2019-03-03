defprotocol Parear.ParticipantRepository do
  @doc "Inserts a participant into a stairs. It returns either {:ok, term} or {:error, reason}"
  def insert(participant, stairs)

  @doc "Retrieves a participant by its id. It returns either {:ok, term} or {:none}"
  def find_by_id(participant_with_id)
end

defmodule Parear.ParticipantRepository do
  alias Parear.Participant

  @callback find_by_id(String.t()) :: {:ok, %Participant{}} | {:error, String.t()} | {:none}
  @callback insert(%Participant{}, String.t()) :: {:ok, %Participant{}} | {:error, String.t()}
end

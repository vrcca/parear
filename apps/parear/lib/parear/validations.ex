defmodule Parear.Validations do
  alias Parear.{Stairs, Participant}

  def prepare_with(stairs, participant, another_participant) do
    fn type ->
      validate(stairs, participant, another_participant, type)
    end
  end

  def validate(error = {:error, _msg}, _participant, _another_participant, _type), do: error

  def validate(
        stairs = %Stairs{participants: participants},
        participant,
        another_participant,
        :participants_exist
      ) do
    cond do
      nil == participant || nil == another_participant ->
        {:error, "unknown_participant"}

      not Map.has_key?(participants, participant.id) ->
        {:error, "unknown_participant"}

      not Map.has_key?(participants, another_participant.id) ->
        {:error, "unknown_participant"}

      true ->
        {:ok, stairs}
    end
  end

  def validate(
        stairs = %Stairs{limit: limit},
        participant = %Participant{},
        %Participant{id: another_id},
        :pair_limit
      ) do
    statuses = Stairs.statuses_for_participant(stairs, participant) || %{}
    current_total = Map.get(statuses, another_id) || 0

    cond do
      current_total >= limit ->
        {:error, "maximum_limit_reached"}

      true ->
        {:ok, stairs}
    end
  end

  def then({:ok, stairs}, fun), do: {:ok, fun.(stairs)}
  def then(error, _fun), do: error
end

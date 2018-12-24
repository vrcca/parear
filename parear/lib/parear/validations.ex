defmodule Parear.Validations do
  alias Parear.Stairs

  def validate(error = {:error, _msg}, _name, _another_name, _type), do: error

  def validate({:ok, stairs}, name, another_name, type),
    do: validate(stairs, name, another_name, type)

  def validate(
        stairs = %Stairs{participants: participants},
        name,
        another_name,
        :participants_exist
      ) do
    cond do
      not Map.has_key?(participants, name) ->
        {:error, "unknown_participant"}

      not Map.has_key?(participants, another_name) ->
        {:error, "unknown_participant"}

      true ->
        {:ok, stairs}
    end
  end

  def validate(stairs = %Stairs{limit: limit}, name, another_name, :pair_limit) do
    current_total = stairs.participants[name][another_name]

    cond do
      current_total == limit ->
        {:error, "maximum_limit_reached"}

      true ->
        {:ok, stairs}
    end
  end

  def then({:ok, stairs}, fun), do: {:ok, fun.(stairs)}
  def then(error, _fun), do: error
end

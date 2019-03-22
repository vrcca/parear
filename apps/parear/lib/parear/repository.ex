defmodule Parear.Repository do
  alias Parear.Stairs

  @callback find_by_id(String.t()) :: {:ok, %Stairs{}} | {:error, String.t()} | {:none}
  @callback find_by_name(String.t()) :: {:ok, %Stairs{}} | {:error, String.t()} | {:none}
  @callback save(%Stairs{}) :: {:ok, %Stairs{}} | {:error, String.t()}
end

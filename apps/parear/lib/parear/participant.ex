defmodule Parear.Participant do
  alias Parear.Participant

  @enforce_keys [:id]
  defstruct id: nil, name: nil

  def new(opts) when is_list(opts) do
    struct!(Participant, opts)
  end

  def new(name, opts \\ []) do
    %Participant{id: UUID.uuid4(), name: name}
    |> struct!(opts)
  end
end

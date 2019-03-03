defmodule Parear.Participant do
  alias Parear.Participant

  defstruct id: nil, name: nil

  def new(name) do
    %Participant{id: UUID.uuid4(), name: name}
  end
end

defmodule Parear.DynamicSupervisor do
  use DynamicSupervisor

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def start_child(name, options \\ []) do
    spec = %{
      id: Parear.Servers,
      start: {
        Parear.Server,
        :start_link,
        [%{name: name, options: options}]
      }
    }

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [arg]
    )
  end
end

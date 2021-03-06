defmodule Parear.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: Parear.DynamicSupervisor},
      {Registry, keys: :unique, name: Registry.Stairs}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end

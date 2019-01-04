defmodule Repository.Application do
  use Application

  def start(_type, _args) do
    children = [
      Repository.Stairs,
      Repository.Parear.Repo
    ]

    opts = [
      strategy: :one_for_one,
      name: Repository.Supervisor
    ]

    Supervisor.start_link(children, opts)
  end
end

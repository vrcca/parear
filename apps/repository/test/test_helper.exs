ExUnit.start()
ExUnit.configure(exclude: :pending)
Ecto.Adapters.SQL.Sandbox.mode(Repository.Parear.Repo, :manual)

defmodule Repository do
  defdelegate find_by_id(id), to: Repository.Stairs
  defdelegate save(stairs), to: Repository.Stairs
end

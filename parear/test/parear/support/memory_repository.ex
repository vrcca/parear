defmodule Parear.Support.MemoryRepository do
  alias Parear.{Stairs, ParticipantRepository, Participant, Repository}
  alias Parear.Support.MemoryRepository

  use Agent

  @repo __MODULE__

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: @repo)
  end

  def get_by_id(id) do
    Agent.get(@repo, fn state ->
      Map.get(state, id)
    end)
  end

  def get_by_name(name) do
    Agent.get(@repo, fn state ->
      Enum.find(state, fn {_id, value} ->
        value.name == name
      end)
    end)
  end

  def save(id, value) do
    Agent.update(@repo, fn state ->
      Map.put(state, id, value)
    end)
  end

  defimpl Repository, for: Stairs do
    def find_by_id(%Stairs{id: id}) do
      MemoryRepository.get_by_id(id)
      |> MemoryRepository.respond_to_find()
    end

    def find_by_name(%Stairs{name: name}) do
      MemoryRepository.get_by_name(name)
      |> MemoryRepository.respond_to_find()
    end

    def save(stairs = %Stairs{id: id}) do
      with :ok <- MemoryRepository.save(id, stairs) do
        stairs
      end
    end
  end

  defimpl ParticipantRepository, for: Participant do
    def find_by_id(%Participant{id: id}) do
      MemoryRepository.get_by_id(id)
      |> MemoryRepository.respond_to_find()
    end

    def insert(participant = %Participant{id: id}, stairs = %Stairs{id: stairs_id}) do
      with :ok <- MemoryRepository.save(stairs_id, stairs),
           :ok <- MemoryRepository.save(id, participant) do
        {:ok, participant}
      end
    end
  end

  def respond_to_find(nil), do: {:none}
  def respond_to_find({_id, value}), do: {:ok, value}
  def respond_to_find(value), do: {:ok, value}
end

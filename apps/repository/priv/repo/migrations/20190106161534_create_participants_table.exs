defmodule Repository.Parear.Repo.Migrations.CreateParticipantsTable do
  use Ecto.Migration

  def change do
    create table(:participants, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :stair_id, references(:stairs, type: :binary_id)
      timestamps()
    end
  end
end

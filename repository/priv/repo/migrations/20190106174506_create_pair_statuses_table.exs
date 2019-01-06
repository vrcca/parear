defmodule Repository.Parear.Repo.Migrations.CreatePairStatusesTable do
  use Ecto.Migration

  def change do
    create table(:pair_statuses) do
      add :participant_id, references(:participants)
      add :friend_id, references(:participants)
      add :stair_id, references(:stairs)
      add :total, :integer, default: 0
      timestamps()
    end

    create unique_index(:pair_statuses, [:stair_id, :participant_id, :friend_id])
  end
end

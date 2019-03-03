defmodule Repository.Parear.Repo.Migrations.CreatePairStatusesTable do
  use Ecto.Migration

  def change do
    create table(:pair_statuses, primary_key: false) do
      add :participant_id, references(:participants, type: :binary_id), primary_key: true
      add :friend_id, references(:participants, type: :binary_id), primary_key: true
      add :stair_id, references(:stairs, type: :binary_id), primary_key: true
      add :total, :integer, default: 0
      timestamps()
    end
  end
end

defmodule Repository.Parear.Repo.Migrations.CreateParticipantsTable do
  use Ecto.Migration

  def change do
    create table(:participants) do
      add :name, :string
      add :stair_id, references(:stairs)

      timestamps()
    end
  end
end

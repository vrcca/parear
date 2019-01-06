defmodule Repository.Parear.Repo.Migrations.CreateStairs do
  use Ecto.Migration

  def change do
    create table(:stairs) do
      add :name, :string
      add :limit, :integer, default: 5

      timestamps()
    end
  end
end

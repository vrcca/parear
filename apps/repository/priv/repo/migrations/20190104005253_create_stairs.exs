defmodule Repository.Parear.Repo.Migrations.CreateStairs do
  use Ecto.Migration

  def change do
    create table(:stairs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :limit, :integer, default: 5
      timestamps()
    end
  end
end

defmodule Dessousaine.Repo.Migrations.CreateSamuserEvents do
  use Ecto.Migration

  def change do
    create table(:samuser_events) do
      add :provider, :string, null: false
      add :title, :string, null: false
      add :date, :string
      add :tag, :string
      add :photo_url, :text
      add :url, :text
      add :museum_name, :string, null: false
      add :checksum, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:samuser_events, [:provider, :checksum])
    create index(:samuser_events, [:provider])
    create index(:samuser_events, [:inserted_at])
  end
end

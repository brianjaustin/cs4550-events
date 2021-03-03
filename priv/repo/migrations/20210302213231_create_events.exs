defmodule Events.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string, null: false
      add :date, :naive_datetime, null: false
      add :description, :text
      add :organizer_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:events, [:organizer_id])
  end
end

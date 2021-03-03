defmodule Events.Repo.Migrations.CreateEventParticipant do
  use Ecto.Migration

  def change do
    create table(:event_participant, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all), primary_key: true
      add :event_id, references(:events, on_delete: :delete_all), primary_key: true
      add :status, :string, null: false
      add :comments, :string

      timestamps()
    end

  end
end

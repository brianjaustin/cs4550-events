defmodule Events.Repo.Migrations.AddUserProfilePic do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :photo_hash, :text
    end
  end
end

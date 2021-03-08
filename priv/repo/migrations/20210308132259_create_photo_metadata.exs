defmodule Events.Repo.Migrations.CreatePhotoMetadata do
  use Ecto.Migration

  def change do
    create table(:photo_metadata, primary_key: false) do
      add :hash, :string, primary_key: true
      add :references, :integer, null: false

      timestamps()
    end

  end
end

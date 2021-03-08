defmodule Events.Photos.Metadata do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "photo_metadata" do
    field :hash, :string, primary_key: true
    field :references, :integer

    timestamps()
  end

  @doc false
  def changeset(metadata, attrs) do
    metadata
    |> cast(attrs, [:hash, :references])
    |> validate_required([:hash, :references])
  end
end

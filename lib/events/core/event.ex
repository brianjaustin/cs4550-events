defmodule Events.Core.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :date, :naive_datetime
    field :description, :string
    field :name, :string
    belongs_to :organizer, Events.Users.User
    has_many :participants, Events.Core.EventParticipant

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :date, :description, :organizer_id])
    |> validate_required([:name, :date, :organizer_id])
  end
end

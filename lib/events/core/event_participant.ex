defmodule Events.Core.EventParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "event_participant" do
    belongs_to :user, Events.Users.User, primary_key: true
    belongs_to :event, Events.Core.Event, primary_key: true
    field :comments, :string
    field :status, Ecto.Enum, values: [:yes, :maybe, :no, :unknown]

    timestamps()
  end

  @doc false
  def changeset(event_participant, attrs) do
    event_participant
    |> cast(attrs, [:user, :event, :status, :comments])
    |> validate_required([:user, :event, :status])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:event_id)
    |> unique_constraint([:user, :event],
      name: :user_id_event_id_unique_index,
      message: "Already responded for event")
  end
end

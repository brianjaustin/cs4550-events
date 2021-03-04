defmodule Events.Core.EventParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "event_participant" do
    belongs_to :event, Events.Core.Event, primary_key: true
    field :email, :string, primary_key: true
    field :comments, :string
    field :status, Ecto.Enum, values: [:yes, :maybe, :no, :unknown]

    timestamps()
  end

  @doc false
  def changeset(event_participant, attrs) do
    event_participant
    |> cast(attrs, [:email, :status, :comments, :event_id])
    |> validate_required([:email, :event_id])
    # Python Regex from http://emailregex.com/
    |> validate_format(:email, ~r/^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/)
    |> unique_constraint([:event_id, :email],
      name: :user_id_event_id_unique_index,
      message: "Already invited to event")
  end

end

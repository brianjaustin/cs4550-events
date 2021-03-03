defmodule Events.Core.EventParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "event_participant" do
    belongs_to :event, Events.Core.Event, primary_key: true
    field :email, :string, primary_key: true
    field :comments, :string
    field :status, Ecto.Enum, values: [:yes, :maybe, :no, :unknown]

    # Virtual field used to let us know when to delete/recreate
    # this participant. See `nested_changest` for attribution.
    field :delete, :boolean, virtual: true

    timestamps()
  end

  @doc false
  def changeset(event_participant, attrs) do
    event_participant
    |> cast(attrs, [:email, :status, :comments])
    |> cast_assoc(:event, required: True)
    |> validate_required([:event_id, :email])
    # Python Regex from http://emailregex.com/
    |> validate_format(:email, ~r/^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/)
    |> unique_constraint([:event_id, :email],
      name: :user_id_event_id_unique_index,
      message: "Already invited to event")
  end

  @doc """
  Used for manipulating participants from the parent object,
  events. We don't use `cast_assoc` because the parent will
  take care of that.

  ## Attribution

    Based on the example from
    https://bash-shell.net/blog/phoenix-django-devs-inline-formset-nested-changesets-part-1/.
  """
  def nested_changeset(event_participant, attrs) do
    event_participant
    |> cast(attrs, [:email, :status, :comments])
    |> validate_required([:email])
    |> mark_for_deletion()
  end

  defp mark_for_deletion(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end

end

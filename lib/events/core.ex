defmodule Events.Core do
  @moduledoc """
  The Core context.
  """

  import Ecto.Query, warn: false
  alias Events.Repo

  alias Events.Core.Event
  alias Events.Core.EventParticipant

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events do
    Repo.all(Event)
  end

  @doc """
  Returns the list of participants for an event id.

  ## Examples

    iex> list_event_participants(3)
    [%EventParticipant{}, ...]

    iex> list_event_participants(-1)
    []
  """
  def list_event_participants(event_id) do
    Repo.all(from(EventParticipant, where: [event_id: ^event_id]))
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id), do: Repo.get!(Event, id)

  @doc """
  Gets a single event participant.

  Raises `Ecto.NoResultsError` if the EventParticipant does not exist.

  ## Examples

    iex> get_event_participant!("foo@example.com", 123)
    %EventParticipant{}

    iex> get_event_participant!("baz@bad.net", 456)
    ** (Ecto.NoResultsError)
  """
  def get_event_participant!(email, event_id) do
    Repo.one!(from(EventParticipant, where: [email: ^email, event_id: ^event_id]))
  end

  @doc """
  Creates an event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates am event participant.

  ## Examples

      iex> create_event_participant(%{field: value})
      {:ok, %EventParticipant{}}

      iex> create_event_participant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def create_event_participant(attrs \\ %{}) do
    %EventParticipant{}
    |> EventParticipant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates an event participant.

  ## Examples

      iex> update_event_participant(participant, %{field: new_value})
      {:ok, %EventParticipant{}}

      iex> update_event_participant(participant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event_participant(%EventParticipant{} = participant, attrs) do
    participant
    |> EventParticipant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Deletes an event participant.

  ## Examples

    iex> delete_event_participant(participant)
    {:ok, %EventParticipant{}}

    iex> delete_event_participant(participant)
    {:error, %Ecto.Changeset{}}
  """
  def delete_event_participant(%EventParticipant{} = participant) do
    Repo.delete(participant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{data: %Event{}}

  """
  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event participant changes.

  ## Examples

      iex> change_event_participant(EventParticipant)
      %Ecto.Changeset{data: %Event{}}

  """
  def change_event_participant(%EventParticipant{} = participant, attrs \\ %{}) do
    EventParticipant.changeset(participant, attrs)
  end
end

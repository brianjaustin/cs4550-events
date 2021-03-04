defmodule EventsWeb.EventController do
  use EventsWeb, :controller

  alias Events.Core
  alias Events.Core.Event
  alias Events.Users
  alias Events.Repo

  def index(conn, _params) do
    events = Core.list_events()
    |> Repo.preload(:organizer)
    render(conn, "index.html", events: events)
  end

  def new(conn, _params) do
    changeset = Core.change_event(%Event{})
    organizers = Users.list_users()
    |> Enum.map(&{&1.email, &1.id})
    render(conn, "new.html", changeset: changeset, organizers: organizers)
  end

  def create(conn, %{"event" => event_params}) do
    case Core.create_event(event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event created successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        organizers = Users.list_users()
        |> Enum.map(&{&1.email, &1.id})
        render(conn, "new.html", changeset: changeset, organizers: organizers)
    end
  end

  def show(conn, %{"id" => id}) do
    event = Core.get_event!(id)
    |> Repo.preload(:organizer)
    |> Repo.preload(:participants)
    participants = count_participants(event)
    render(conn, "show.html", event: event, participant_summary: participants)
  end

  defp count_participants(event) do
    event.participants
    |> Enum.reduce({0, 0, 0, 0}, fn participant, {y, m, n, u} ->
      case participant.status do
        :yes -> {y + 1, m, n, u}
        :maybe -> {y, m + 1, n, u}
        :no -> {y, m, n + 1, u}
        :unknown -> {y, m, n, u + 1}
      end
    end)
    |> stringify_participants()
  end

  defp stringify_participants({yes, maybe, no, unknown}) do
    "#{yes} yes, #{maybe} maybe, #{no} no, #{unknown} no response"
  end

  def edit(conn, %{"id" => id}) do
    event = Core.get_event!(id)
    |> Repo.preload(:participants)
    changeset = Core.change_event(event)
    organizers = Users.list_users()
    |> Enum.map(&{&1.email, &1.id})

    render(conn, "edit.html", event: event, changeset: changeset,
      organizers: organizers)
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    event = Core.get_event!(id)
    |> Repo.preload(:participants)

    case Core.update_event(event, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        organizers = Users.list_users()
        |> Enum.map(&{&1.email, &1.id})
        render(conn, "edit.html", event: event,
        changeset: changeset, organizers: organizers)
    end
  end

  def delete(conn, %{"id" => id}) do
    event = Core.get_event!(id)
    {:ok, _event} = Core.delete_event(event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> redirect(to: Routes.event_path(conn, :index))
  end
end

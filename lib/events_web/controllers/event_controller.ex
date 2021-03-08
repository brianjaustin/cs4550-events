defmodule EventsWeb.EventController do
  use EventsWeb, :controller

  alias Events.Core
  alias Events.Core.Event
  alias Events.Repo

  plug EventsWeb.Plugs.RequireUser when action in [
    :new, :create, :edit, :update, :delete
  ]

  plug :fetch_event when action in [
    :show, :edit, :update, :delete
  ]
  plug :require_organizer when action in [
    :edit, :update, :delete
  ]

  def fetch_event(conn, _params) do
    id = conn.params["id"]
    event = Core.get_event!(id)
    assign(conn, :event, event)
  end

  def require_organizer(conn, _params) do
    user = conn.assigns[:current_user]
    event = conn.assigns[:event]
    |> Repo.preload(:organizer)

    if user.id == event.organizer.id do
      conn
    else
      conn
      |> put_flash(:error, "Cannot edit an event belonging to someone else.")
      |> redirect(to: Routes.event_path(conn, :show, event.id))
      |> halt()
    end
  end

  def index(conn, _params) do
    events = Core.list_events()
    |> Repo.preload(:organizer)
    render(conn, "index.html", events: events)
  end

  def new(conn, _params) do
    changeset = Core.change_event(%Event{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"event" => event_params}) do
    event_params = event_params
    |> Map.put("organizer_id", conn.assigns[:current_user].id)

    case Core.create_event(event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event created successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => _id}) do
    event = conn.assigns[:event]
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

  def edit(conn, %{"id" => _id}) do
    event = conn.assigns[:event]
    |> Repo.preload(:participants)
    changeset = Core.change_event(event)

    render(conn, "edit.html", event: event, changeset: changeset)
  end

  def update(conn, %{"id" => _id, "event" => event_params}) do
    event = conn.assigns[:event]
    |> Repo.preload(:participants)

    case Core.update_event(event, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", event: event,
        changeset: changeset)
    end
  end

  def delete(conn, %{"id" => _id}) do
    event = conn.assigns[:event]
    {:ok, _event} = Core.delete_event(event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> redirect(to: Routes.event_path(conn, :index))
  end
end

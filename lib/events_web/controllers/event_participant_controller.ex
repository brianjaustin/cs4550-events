defmodule EventsWeb.EventParticipantController do
  use EventsWeb, :controller

  alias Events.Core
  alias Events.Core.EventParticipant
  alias Events.Repo

  plug EventsWeb.Plugs.RequireUser when action in [
    :new, :create, :lookup, :search, :edit, :update, :delete
  ]

  plug :fetch_event when action in [
    :new, :create, :lookup, :search, :edit, :update, :delete
  ]
  plug :auth_organizer when action in [
    :new, :create, :delete
  ]
  plug :auth_participant when action in [
    :edit, :update
  ]

  def fetch_event(conn, _params) do
    id = conn.params["eventId"]
    event = Core.get_event!(id)
    assign(conn, :event, event)
  end

  def auth_organizer(conn, _params) do
    user = conn.assigns[:current_user]
    event = conn.assigns[:event]
    |> Repo.preload(:organizer)

    if user.id == event.organizer.id do
      conn
    else
      conn
      |> put_flash(:error, "Only organizers of an event can change its invite list")
      |> redirect(to: Routes.event_path(conn, :show, event.id))
      |> halt()
    end
  end

  def auth_participant(conn, _params) do
    user = conn.assigns[:current_user]
    event = conn.assigns[:event]
    |> Repo.preload(:organizer)
    participant = conn.params["email"]

    if user.email == participant || user.id == event.organizer.id do
      conn
    else
      conn
      |> put_flash(:error, "Cannot RSVP for someone else")
      |> redirect(to: Routes.event_path(conn, :show, event.id))
      |> halt()
    end
  end

  def new(conn, %{"eventId" => _event_id}) do
    event = conn.assigns[:event]
    changeset = Core.change_event_participant(%EventParticipant{})
    render(conn, "new.html", changeset: changeset, event: event)
  end

  def create(conn, %{"eventId" => event_id, "event_participant" => participant_params}) do
    participant_params = participant_params
    |> Map.put("event_id", event_id)

    case Core.create_event_participant(participant_params) do
      {:ok, _participant} ->
        conn
        |> put_flash(:info, "Event participant created successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        event = conn.assigns[:event]
        render(conn, "new.html", changeset: changeset, event: event)
    end
  end

  def lookup(conn, %{"eventId" => _event_id}) do
    event = conn.assigns[:event]
    user = conn.assigns[:current_user]

    conn
    |> assign(:email, user.email)
    |> redirect(to: Routes.event_participant_path(conn, :edit, event.id, user.email))
  end

  def edit(conn, %{"eventId" => event_id, "email" => email}) do
    event = conn.assigns[:event]
    participant = Core.get_event_participant!(email, event_id)
    changeset = Core.change_event_participant(participant)
    render(conn, "edit.html", participant: participant,
      event: event, changeset: changeset)
  end

  def update(conn, %{"eventId" => event_id, "email" => email,
    "event_participant" => participant_params}) do
    participant = Core.get_event_participant!(email, event_id)
    
    case Core.update_event_participant(participant, participant_params) do
      {:ok, _participant} ->
        conn
        |> put_flash(:info, "Event participant updated successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        event = conn.assigns[:event]
        render(conn, "edit.html", participant: participant, event: event, changeset: changeset)
    end
  end

  def delete(conn, %{"eventId" => event_id, "email" => email}) do
    participant = Core.get_event_participant!(email, event_id)
    {:ok, _participant} = Core.delete_event_participant(participant)

    conn
    |> put_flash(:info, "Event participant deleted successfully.")
    |> redirect(to: Routes.event_path(conn, :show, event_id))
  end

end

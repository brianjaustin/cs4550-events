defmodule EventsWeb.EventParticipantController do
  use EventsWeb, :controller

  alias Events.Core
  alias Events.Core.EventParticipant
  alias Events.Users

  def new(conn, %{"eventId" => event_id}) do
    event = Core.get_event!(event_id)
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
        event = Core.get_event!(event_id)
        render(conn, "new.html", changeset: changeset, event: event)
    end
  end

  def lookup(conn, %{"eventId" => event_id}) do
    event = Core.get_event!(event_id)
    render(conn, "lookup.html", event: event)
  end

  def search(conn, %{"eventId" => event_id, "email" => email}) do
    case Core.get_event_participant(email, event_id) do
      %EventParticipant{} ->
        redirect(conn, to: Routes.event_participant_path(conn, :edit, event_id, email))
      _ ->
        event = Core.get_event!(event_id)
        conn
        |> put_flash(:error, "Participant not found with email #{email}")
        |> render("lookup.html", event: event)
    end
  end

  def edit(conn, %{"eventId" => event_id, "email" => email}) do
    if Users.get_user_by_email(email) do
      event = Core.get_event!(event_id)
      participant = Core.get_event_participant!(email, event_id)
      changeset = Core.change_event_participant(participant)
      render(conn, "edit.html", participant: participant,
        event: event, changeset: changeset)
    else
      conn
      |> put_flash(:info, "Welcome new user! Please register to RSVP.")
      |> redirect(to: Routes.user_path(conn, :new, next: conn.request_path))
    end
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
        event = Core.get_event!(event_id)
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

defmodule EventsWeb.EventParticipantController do
  use EventsWeb, :controller

  alias Events.Core
  alias Events.Core.EventParticipant
  alias Events.Repo

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
    end
  end

  def edit(conn, %{"eventId" => event_id, "email" => email}) do
    event = Core.get_event!(event_id)
    participant = Core.get_event_participant!(email, event_id)
    changeset = Core.change_event_participant(participant)
    render(conn, "edit.html", participant: participant, event: event, changeset: changeset)
  end

  def update(conn, %{"eventId" => event_id, "email" => email,
    "event_participant" => participant_params}) do
    participant = Core.get_event_participant!(email, event_id)
    
    case Core.update_event_participant(participant, participant_params) do
      {:ok, _participant} ->
        conn
        |> put_flash(:info, "Event participant updated successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event_id))
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

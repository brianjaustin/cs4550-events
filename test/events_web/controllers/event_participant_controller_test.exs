defmodule EventsWeb.EventParticipantControllerTest do
  use EventsWeb.ConnCase

  alias Events.Core
  alias Events.Users
  alias Events.Repo

  @create_attrs %{email: "participant@example.com"}
  @update_attrs %{status: :yes, comments: "comment"}
  @invalid_attrs %{email: "not-an-email", status: :bad}

  def fixture(:user) do
    {:ok, user} = %{email: "email@example.com", name: "some name"}
    |> Users.create_user()
    user
  end

  def fixture(:event) do
    user = fixture(:user)

    {:ok, event} = %{date: ~N[2010-04-17 14:00:00], description: "some description", name: "some name"}
    |> Map.put(:organizer_id, user.id)
    |> Core.create_event()
    event
  end

  def fixture(:participant) do
    event = fixture(:event)

    {:ok, participant} = @create_attrs
    |> Map.put(:event_id, event.id)
    |> Core.create_event_participant()

    participant
    |> Repo.preload(:event)
  end

  describe "new participant" do
    setup [:create_event]

    test "renders form for event", %{conn: conn, event: event} do
      conn = get(conn, Routes.event_participant_path(conn, :new, event.id))
      response = html_response(conn, 200)

      assert response =~ "Add Event Participant"
      assert response =~ "Event: #{event.name}"
      assert response =~ "Email"
      # We don't allow setting response on invitation creation
      refute response =~ "Status"
    end
  end

  describe "create participant" do
    setup [:create_event]

    test "redirects to event details when input is valid", %{conn: conn, event: event} do
      conn = post(conn,
        Routes.event_participant_path(conn, :create, event.id),
        event_participant: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.event_path(conn, :show, id)

      conn = get(conn, Routes.event_path(conn, :show, id))
      response = html_response(conn, 200)
      assert response =~ "Show Event"
      assert response =~ event.name
    end

    test "renders error when email is invalid", %{conn: conn, event: event} do
      conn = post(conn,
        Routes.event_participant_path(conn, :create, event.id),
          event_participant: @invalid_attrs)
      assert html_response(conn, 200) =~ "Add Event Participant"
    end
  end

  describe "lookup participant" do
    setup [:create_event]

    test "renders form for existing event", %{conn: conn, event: event} do
      conn = get(conn, Routes.event_participant_path(conn, :lookup, event.id))
      assert html_response(conn, 200) =~ "Enter your email"
    end

    test "errors for non-existent event", %{conn: conn, event: _event} do
      assert_error_sent 404, fn ->
        get(conn, Routes.event_participant_path(conn, :lookup, -1))
      end
    end
  end

  describe "search participants" do
    setup [:create_participant]

    test "redirects to edit for existing", %{conn: conn, participant: p} do
      conn = post(conn,
        Routes.event_participant_path(conn, :search, p.event.id),
        email: p.email)
      assert redirected_to(conn) ==
        Routes.event_participant_path(conn, :edit, p.event.id, p.email)
    end
    
    test "displays error for nonexistent", %{conn: conn, participant: p} do
      conn = post(conn,
        Routes.event_participant_path(conn, :search, p.event.id, email: "bad-email"))
      assert html_response(conn, 200) =~ "Participant not found with email bad-email"
    end
  end

  describe "edit participant" do
    setup [:create_participant]
    
    test "renders form for editing the chose participant",
      %{conn: conn, participant: participant} do
      conn = get(conn, Routes.event_participant_path(conn,
        :edit,
        participant.event.id,
        participant.email))
      assert html_response(conn, 200) =~ "Edit Participant"
    end
  end

  describe "update participant" do
    setup [:create_participant]

    test "redirects to event when updates are valid",
      %{conn: conn, participant: participant} do
      event_id = participant.event.id
      conn = put(conn,
        Routes.event_participant_path(conn, :update, event_id, participant.email),
        event_participant: @update_attrs)
      assert redirected_to(conn) == Routes.event_path(conn, :show, event_id)

      conn = get(conn, Routes.event_path(conn, :show, event_id))
      response = html_response(conn, 200)
      assert response =~ "Show Event"
      assert response =~ "yes"
      assert response =~ "comment"
      refute response =~ "hasn't responded"
    end

    test "renders error when data is invalid",
      %{conn: conn, participant: participant} do
        event_id = participant.event.id
        conn = put(conn,
        Routes.event_participant_path(conn, :update, event_id, participant.email),
          event_participant: @invalid_attrs)
        assert html_response(conn, 200) =~ "Edit Participant"
    end
  end

  describe "delete participant" do
    setup [:create_participant]

    test "removes the chosen participant",
      %{conn: conn, participant: participant} do
      event_id = participant.event.id
      conn = delete(conn,
        Routes.event_participant_path(conn, :delete, event_id, participant.email))
      assert redirected_to(conn) == Routes.event_path(conn, :show, event_id)

      assert_error_sent 404, fn ->
        get(conn, Routes.event_participant_path(conn, :edit, event_id, participant.email))
      end
    end
  end

  defp create_event(_) do
    event = fixture(:event)
    %{event: event}
  end

  defp create_participant(_) do
    participant = fixture(:participant)
    %{participant: participant}
  end
end

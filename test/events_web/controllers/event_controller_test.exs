defmodule EventsWeb.EventControllerTest do
  use EventsWeb.ConnCase

  alias Events.Core
  alias Events.Users

  @create_attrs %{date: ~N[2010-04-17 14:00:00], description: "some description", name: "some name"}
  @update_attrs %{date: ~N[2011-05-18 15:01:01], description: "some updated description", name: "some updated name"}
  @invalid_attrs %{date: nil, description: nil, name: nil}

  def fixture(:user) do
    {:ok, user} = %{email: "email@example.com", name: "some name"}
    |> Users.create_user()
    user
  end

  def fixture(:event) do
    user = fixture(:user)

    {:ok, event} = @create_attrs
    |> Map.put(:organizer_id, user.id)
    |> Core.create_event()
    event
  end

  describe "index" do
    test "lists all events", %{conn: conn} do
      conn = get(conn, Routes.event_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Events"
    end
  end

  describe "new event" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.event_path(conn, :new))
      assert html_response(conn, 200) =~ "New Event"
    end
  end

  describe "create event" do
    setup [:create_user]

    test "redirects to show when data is valid", %{conn: conn, user: user} do
      params = Map.put(@create_attrs, :organizer_id, user.id)
      conn = post(conn, Routes.event_path(conn, :create), event: params)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.event_path(conn, :show, id)

      conn = get(conn, Routes.event_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Event"
    end

    test "renders errors when data is invalid", %{conn: conn, user: _user} do
      conn = post(conn, Routes.event_path(conn, :create), event: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Event"
    end
  end

  describe "edit event" do
    setup [:create_event]

    test "renders form for editing chosen event", %{conn: conn, event: event} do
      conn = get(conn, Routes.event_path(conn, :edit, event))
      assert html_response(conn, 200) =~ "Edit Event"
    end
  end

  describe "update event" do
    setup [:create_event]

    test "redirects when data is valid", %{conn: conn, event: event} do
      conn = put(conn, Routes.event_path(conn, :update, event), event: @update_attrs)
      assert redirected_to(conn) == Routes.event_path(conn, :show, event)

      conn = get(conn, Routes.event_path(conn, :show, event))
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, event: event} do
      conn = put(conn, Routes.event_path(conn, :update, event), event: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Event"
    end
  end

  describe "delete event" do
    setup [:create_event]

    test "deletes chosen event", %{conn: conn, event: event} do
      conn = delete(conn, Routes.event_path(conn, :delete, event))
      assert redirected_to(conn) == Routes.event_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.event_path(conn, :show, event))
      end
    end
  end

  defp create_event(_) do
    event = fixture(:event)
    %{event: event}
  end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end
end

defmodule Events.CoreTest do
  use Events.DataCase

  alias Events.Core
  alias Events.Users

  describe "events" do
    alias Events.Core.Event

    @valid_attrs %{date: ~N[2010-04-17 14:00:00], description: "some description", name: "some name"}
    @update_attrs %{date: ~N[2011-05-18 15:01:01], description: "some updated description", name: "some updated name"}
    @invalid_attrs %{date: nil, description: nil, name: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(%{email: "email@example.com", name: "some name"})
        |> Users.create_user()

      user
    end

    def event_fixture(attrs \\ %{}) do
      user = user_fixture()

      {:ok, event} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:organizer_id, user.id)
        |> Core.create_event()

      event
    end

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Core.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Core.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      user = user_fixture()
      attrs = Map.put(@valid_attrs, :organizer_id, user.id)
      assert {:ok, %Event{} = event} = Core.create_event(attrs)
      assert event.date == ~N[2010-04-17 14:00:00]
      assert event.description == "some description"
      assert event.name == "some name"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()
      assert {:ok, %Event{} = event} = Core.update_event(event, @update_attrs)
      assert event.date == ~N[2011-05-18 15:01:01]
      assert event.description == "some updated description"
      assert event.name == "some updated name"
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Core.update_event(event, @invalid_attrs)
      assert event == Core.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Core.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Core.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Core.change_event(event)
    end
  end
end

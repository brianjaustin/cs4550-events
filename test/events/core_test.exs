defmodule Events.CoreTest do
  use Events.DataCase

  alias Events.Core
  alias Events.Core.Event
  alias Events.Core.EventParticipant
  alias Events.Repo
  alias Events.Users

  describe "events" do
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

  describe "event participants" do
    @valid_attrs %{email: "email@test.com", status: :unknown, comments: "foo"}
    @update_attrs %{status: :no, comments: "bar"}
    @invalid_attrs %{email: "bad-email", status: nil}

    def participant_fixture(attrs \\ %{}) do
      event = event_fixture()

      {:ok, participant} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:event_id, event.id)
        |> Core.create_event_participant()

      participant
      |> Repo.preload(:event)
    end

    test "list_event_participants/1 gets participant for event" do
      participant = participant_fixture()
      result = participant.event.id
      |> Core.list_event_participants()
      |> hd()
      |> Repo.preload(:event)
      assert result == participant
    end

    test "get_event_participant!/1 gets participant with given id" do
      participant = participant_fixture()
      assert participant ==
        Core.get_event_participant!(participant.email, participant.event.id)
        |> Repo.preload(:event)
    end

    test "get_event_participant/1 gets participant with given id" do
      participant = participant_fixture()
      assert participant ==
        Core.get_event_participant(participant.email, participant.event.id)
        |> Repo.preload(:event)
    end

    test "create_participant/1 with valid data creates a event" do
      event = event_fixture()
      attrs = Map.put(@valid_attrs, :event_id, event.id)
      assert {:ok, %EventParticipant{} = participant} =
        Core.create_event_participant(attrs)
      assert participant.email == "email@test.com"
      assert participant.status == :unknown
      assert participant.comments == "foo"
    end

    test "create_event_participant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_event_participant(@invalid_attrs)
    end

    test "update_event_participant/2 with valid data updates the event" do
      participant = participant_fixture()
      assert {:ok, %EventParticipant{} = participant} =
        Core.update_event_participant(participant, @update_attrs)
      assert participant.status == :no
      assert participant.comments == "bar"
    end

    test "update_event_participant/2 with invalid data returns error changeset" do
      participant = participant_fixture()
      assert {:error, %Ecto.Changeset{}} =
        Core.update_event_participant(participant, @invalid_attrs)
      assert participant ==
        Core.get_event_participant!(participant.email, participant.event.id)
        |> Repo.preload(:event)
    end

    test "delete_event_participant/1 deletes the participant" do
      participant = participant_fixture()
      assert {:ok, %EventParticipant{}} = Core.delete_event_participant(participant)
      assert_raise Ecto.NoResultsError, fn ->
        Core.get_event_participant!(participant.email, participant.event.id)
      end
    end

    test "change_event_participant/1 returns an event participant changeset" do
      participant = participant_fixture()
      assert %Ecto.Changeset{} = Core.change_event_participant(participant)
    end
  end
end

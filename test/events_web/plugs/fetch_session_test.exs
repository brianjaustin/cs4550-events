defmodule EventsWeb.Plugs.FetchSessionTest do
  use EventsWeb.ConnCase

  alias Events.Users
  alias EventsWeb.Plugs.FetchSession

  @create_attrs %{email: "email@example.com", name: "some name"}

  def fixture(:user) do
    {:ok, user} = Users.create_user(@create_attrs)
    user
  end

  describe "setting current user" do
    setup [:create_user]

    test "existing user id in session", %{conn: conn, user: user} do
      conn = conn
      |> Plug.Test.init_test_session(user_id: user.id)
      |> FetchSession.call(%{})

      assert conn.assigns.current_user == user
    end

    test "non-existent user id in session", %{conn: conn} do
      conn = conn
      |> Plug.Test.init_test_session(user_id: -1)
      |> FetchSession.call(%{})

      assert conn.assigns.current_user == nil
    end

    test "no user id in session", %{conn: conn} do
      conn = conn
      |> Plug.Test.init_test_session(user_id: nil)
      |> FetchSession.call(%{})

      assert conn.assigns.current_user == nil
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end
end

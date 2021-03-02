defmodule EventsWeb.SessionControllerTest do
  use EventsWeb.ConnCase

  alias Events.Users

  @create_attrs %{email: "email@example.com", name: "some name"}

  def fixture(:user) do
    {:ok, user} = Users.create_user(@create_attrs)
    user
  end

  describe "create" do
    setup [:create_user]

    test "login with nonexistent email", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), email: "foo@example.com")
      assert redirected_to(conn) == Routes.page_path(conn, :index)

      conn = get(conn, Routes.page_path(conn, :index))
      assert html_response(conn, 200) =~ "Login failed."
      assert get_session(conn, :user_id) == nil
    end

    test "login with existing email", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), email: "email@example.com")
      assert redirected_to(conn) == Routes.page_path(conn, :index)

      conn = get(conn, Routes.page_path(conn, :index))
      response = html_response(conn, 200)
      assert response =~ "Welcome, some name!"
      assert response =~ "Logout"
      assert get_session(conn, :user_id) != nil
    end
  end

  describe "delete" do
    test "logout when already logged out", %{conn: conn} do
      conn = delete(conn, Routes.session_path(conn, :delete))
      assert redirected_to(conn) == Routes.page_path(conn, :index)

      conn = get(conn, Routes.page_path(conn, :index))
      assert html_response(conn, 200) =~ "Logged out."
      assert get_session(conn, :user_id) == nil
    end

    test "logout when logged in", %{conn: conn} do
      conn = conn
      |> Plug.Test.init_test_session(user_id: 1)
      |> delete(Routes.session_path(conn, :delete))
      assert redirected_to(conn) == Routes.page_path(conn, :index)

      conn = get(conn, Routes.page_path(conn, :index))
      assert html_response(conn, 200) =~ "Logged out."
      assert get_session(conn, :user_id) == nil
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end
end

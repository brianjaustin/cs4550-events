defmodule EventsWeb.UserControllerTest do
  use EventsWeb.ConnCase

  alias Events.Users

  @create_attrs %{email: "email@example.come", name: "some name"}
  @update_attrs %{email: "email_2@example.come", name: "some updated name"}
  @invalid_attrs %{email: "nil", name: nil}

  def fixture(:user) do
    {:ok, user} = Users.create_user(@create_attrs)
    user
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Users"
    end
  end

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    test "redirects to index when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn,
        Routes.user_path(conn, :create),
        user: @invalid_attrs)
      assert html_response(conn, 200) =~ "New User"
    end

    test "saves photo when provided", %{conn: conn} do
      upload = %Plug.Upload{path: "test/resources/mountains-1412683_640.png"}
      attrs = @create_attrs
      |> Map.put("photo", upload)

      conn = post(conn, Routes.user_path(conn, :create), user: attrs)
      assert redirected_to(conn) == Routes.page_path(conn, :index)

      # NB: this will fail if the image hash changes
      path = "~/.local/data/events/8e/fd78f3bc3891b288e83815c35cfdf0/photo.jpg"
      |> Path.expand()
      assert File.exists?(path)
    end
  end

  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = conn
      |> Plug.Test.init_test_session(user_id: user.id)
      |> get(Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = conn
      |> Plug.Test.init_test_session(user_id: user.id)
      |> put(Routes.user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)

      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "email_2@example.come"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = conn
      |> Plug.Test.init_test_session(user_id: user.id)
      |> put(Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "saves photo when provided", %{conn: conn, user: user} do
      upload = %Plug.Upload{path: "test/resources/mountains-1412683_640.png"}
      attrs = @create_attrs
      |> Map.put("photo", upload)

      conn = conn
      |> Plug.Test.init_test_session(user_id: user.id)
      |> put(Routes.user_path(conn, :update, user), user: attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)

      # NB: this will fail if the image hash changes
      path = "~/.local/data/events/8e/fd78f3bc3891b288e83815c35cfdf0/photo.jpg"
      |> Path.expand()
      assert File.exists?(path)
    end

    test "deletes previous photo", %{conn: conn, user: user} do
      {:ok, hash} = Events.Photos.save_photo("test/resources/mountains-1412683_640.png")
      Users.update_user(user, %{"photo_hash" => hash})

      conn = conn
      |> Plug.Test.init_test_session(user_id: user.id)
      |> put(Routes.user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)

      # NB: this will fail if the image hash changes
      path = "~/.local/data/events/8e/fd78f3bc3891b288e83815c35cfdf0/photo.jpg"
      |> Path.expand()
      refute File.exists?(path)
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = conn
      |> Plug.Test.init_test_session(user_id: user.id)
      |> delete(Routes.user_path(conn, :delete, user))

      assert redirected_to(conn) == Routes.user_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end
end

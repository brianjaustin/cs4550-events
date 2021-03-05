defmodule EventsWeb.UserController do
  use EventsWeb, :controller

  alias Events.Photos
  alias Events.Users
  alias Events.Users.User

  def index(conn, _params) do
    users = Users.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, params) do
    changeset = Users.change_user(%User{})
    render(conn, "new.html",
      changeset: changeset,
      next: Map.get(params, "next") || Routes.page_path(conn, :index))
  end

  def create(conn, %{"user" => user_params}) do
    upload = user_params["photo"]
    user_params = user_params
    |> Map.put("photo_hash", save_photo(upload))

    case Users.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Map.get(user_params, "next"))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    changeset = Users.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)

    upload = user_params["photo"]
    user_params = user_params
    |> Map.put("photo_hash", save_photo(upload))

    case Users.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    {:ok, _user} = Users.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end

  def photo(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    {:ok, data} = Photos.load_photo(user.photo_hash)

    conn
    |> put_resp_content_type("image/jpeg")
    |> send_resp(200, data)
  end

  defp save_photo(nil), do: nil

  defp save_photo(upload) do
    {:ok, hash} = Photos.save_photo(upload.path)
    hash
  end
end

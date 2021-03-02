defmodule EventsWeb.SessionController do
  @moduledoc """
  Controller for managing user sessions in the web application.

  ## Attributions

    The code in this module is based on the PhotoBlog example from lecture, see
    https://github.com/NatTuck/scratch-2021-01/blob/master/notes-4550/11-photoblog/notes.md.
  """

  use EventsWeb, :controller

  def create(conn, %{"email" => email}) do
    user = Events.Users.get_user_by_email(email)
    if user do
      conn
      |> put_session(:user_id, user.id)
      |> put_flash(:info, "Welcome, #{user.name}!")
      |> redirect(to: Routes.page_path(conn, :index))
    else
      conn
      |> put_flash(:error, "Login failed.")
      |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> put_flash(:info, "Logged out.")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end

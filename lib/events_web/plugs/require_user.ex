defmodule EventsWeb.Plugs.RequireUser do
  @moduledoc """
  Custom plug to require that a user has logged in to
  view/access a controller.

  ## Attributions

    This module is based on the code demonstrated in lecture. See
    https://github.com/NatTuck/scratch-2021-01/blob/master/notes-4550/13-access-rules/notes.md#branch-05-access
  """

  use EventsWeb, :controller

  def init(args), do: args

  def call(conn, _args) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "Login required")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end
end

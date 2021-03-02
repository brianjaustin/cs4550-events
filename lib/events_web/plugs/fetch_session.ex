defmodule EventsWeb.Plugs.FetchSession do
  @moduledoc """
  Plug to initialize the current user in a session based on
  the set user id. If none is set, the user will be `nil`.

  ## Attributions

    This module is based on the lecture example, PhotoBlog. See
    https://github.com/NatTuck/scratch-2021-01/blob/master/notes-4550/11-photoblog/notes.md.
  """

  import Plug.Conn

  def init(args), do: args

  def call(conn, _args) do
    user = Events.Users.get_user(get_session(conn, :user_id) || -1)
    if user do
      assign(conn, :current_user, user)
    else
      assign(conn, :current_user, nil)
    end
  end
end

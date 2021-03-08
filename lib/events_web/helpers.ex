defmodule EventsWeb.Helpers do
  @moduledoc """
  Helpers for use throughout the Events web application.

  ## Attribution

    The code in this module is based on examples from lecture. See
    https://github.com/NatTuck/scratch-2021-01/blob/master/notes-4550/13-access-rules/notes.md#branch-05-access.
  """

  def current_user_is?(conn, user_id) do
    current_user = conn.assigns[:current_user]
    current_user && current_user.id == user_id
  end

  def current_user_in?(conn, user_ids) do
    current_user = conn.assigns[:current_user]
    current_user && current_user.id in user_ids
  end
end

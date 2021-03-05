defmodule Events.Photos do
  @moduledoc """
  This module provides helper functions for dealing with
  users' profile pictures.

  ## Attribution

    The code in this module is based on the photo_blog lecture example. See
    https://github.com/NatTuck/scratch-2021-01/blob/master/4550/0305/photo_blog/lib/photo_blog/photos.ex.
  """

  def save_photo(path) do
    data = File.read!(path)
    hash = sha256(data)

    save_photo(data, hash)
  end

  defp save_photo(data, hash) do
    File.mkdir_p!(base_path(hash))
    File.write!(data_path(hash), data)
    {:ok, hash}
  end

  def load_photo(hash) do
    data = File.read!(data_path(hash))
    {:ok, data}
  end

  defp base_path(hash) do
    Path.expand("~/.local/data/events")
    |> Path.join(String.slice(hash, 0, 2))
    |> Path.join(String.slice(hash, 2, 30))
  end

  defp data_path(hash) do
    Path.join(base_path(hash), "photo.jpg")
  end

  defp sha256(data) do
    :crypto.hash(:sha256, data)
    |> Base.encode16(case: :lower)
  end
end

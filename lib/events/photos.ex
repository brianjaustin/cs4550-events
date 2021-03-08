defmodule Events.Photos do
  @moduledoc """
  This module provides helper functions for dealing with
  users' profile pictures.

  ## Attribution

    The code in this module is based on the photo_blog lecture example. See
    https://github.com/NatTuck/scratch-2021-01/blob/master/4550/0305/photo_blog/lib/photo_blog/photos.ex.
  """

  import Ecto.Query, warn: false

  alias Events.Repo
  alias Events.Photos.Metadata

  @doc """
  Saves a photo with the given temporary path. The permanent
  path will be `~/.local/data/events/{hash_2}/{hash_rest}/photo.jpg
  where `{hash_2}` is the first two characters of the hash of the
  photo and `{hash_rest}` is the remaining characters of that hash.
  """
  def save_photo(path) do
    data = File.read!(path)
    hash = sha256(data)

    save_photo(data, hash)
  end

  defp save_photo(data, hash) do
    # Save the file
    File.mkdir_p!(base_path(hash))
    File.write!(data_path(hash), data)

    # Save the metadata (reference count)
    create_metadata(hash)

    {:ok, hash}
  end

  @doc """
  Given a photo's hash, return the photo with that hash.
  """
  def load_photo(hash) do
    data = File.read!(data_path(hash))
    {:ok, data}
  end

  @doc """
  Handles the case when a user deletes their photo.
  If it's referenced elsewhere we will keep the file.
  Otherwise, the file is deleted.
  """
  def delete_photo(hash) do
    if remove_reference(hash) > 0 do
      {:ok, hash}
    else
      File.rm(data_path(hash))
      {:ok, hash}
    end
  end

  @doc """
  Save metadata associated with a photo (ie reference count).
  If the photo already has metadata, it will be updated as needed.
  """
  def create_metadata(hash) do
    %Metadata{}
    |> Metadata.changeset(%{hash: hash, references: 1})
    |> Repo.insert(conflict_target: :hash, on_conflict: [inc: [references: 1]])
  end

  @doc """
  Updates metadata associated with a photo when it's no longer referenced
  (ie not used anymore).
  """
  def remove_reference(nil), do: nil

  def remove_reference(hash) do
    from(m in Metadata, update: [inc: [references: -1]], where: m.hash == ^hash)
    |> Repo.update_all([])

    Repo.get!(Metadata, hash).references
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

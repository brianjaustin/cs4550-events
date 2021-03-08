defmodule Events.PhotosTests do
  @moduledoc """
  Tests for photo operations.

  ## Attributions

    - https://pixabay.com/vectors/mountains-panorama-forest-mountain-1412683/ is
    the photo used for test cases below.
  """
  use Events.DataCase

  alias Events.Photos
  alias Events.Photos.Metadata
  alias Events.Repo

  describe "save photo" do
    test "writes successfully and inserts metadata" do
      {:ok, hash} = Photos.save_photo("test/resources/mountains-1412683_640.png")

      path = "~/.local/data/events/#{String.slice(hash, 0, 2)}/#{String.slice(hash, 2, 30)}/photo.jpg"
      |> Path.expand()
      assert File.exists?(path)

      metadata = Repo.get!(Metadata, hash)
      assert metadata.references == 1
    end
  end

  describe "delete photo" do
    test "does nothing for nil" do
      {:ok, nil} = Photos.delete_photo(nil)
    end

    test "decrements metadata and removes if only reference" do
      {:ok, hash} = Photos.save_photo("test/resources/mountains-1412683_640.png")
      {:ok, hash} = Photos.delete_photo(hash)

      path = "~/.local/data/events/#{String.slice(hash, 0, 2)}/#{String.slice(hash, 2, 30)}/photo.jpg"
      |> Path.expand()
      refute File.exists?(path)

      metadata = Repo.get!(Metadata, hash)
      assert metadata.references == 0
    end

    test "decrements metadata and does not remove if more references" do
      {:ok, _hash} = Photos.save_photo("test/resources/mountains-1412683_640.png")
      {:ok, hash} = Photos.save_photo("test/resources/mountains-1412683_640.png")
      {:ok, hash} = Photos.delete_photo(hash)

      path = "~/.local/data/events/#{String.slice(hash, 0, 2)}/#{String.slice(hash, 2, 30)}/photo.jpg"
      |> Path.expand()
      assert File.exists?(path)

      metadata = Repo.get!(Metadata, hash)
      assert metadata.references == 1
    end
  end

  describe "create metadata" do
    test "sets reference count 1 for new image" do
      hash = "1234567890abcdefg"
      Photos.create_metadata(hash)

      metadata = Repo.get!(Metadata, hash)
      assert metadata.references == 1
    end

    test "increments reference count for existing image" do
      hash = "1234567890abcdefg"
      Photos.create_metadata(hash)
      Photos.create_metadata(hash)

      metadata = Repo.get!(Metadata, hash)
      assert metadata.references == 2
    end
  end

  describe "remove reference" do
    test "does nothing for nil" do
      refute Photos.remove_reference(nil)
    end

    test "returns new reference count for existing" do
      hash = "1234567890abcdefg"
      Photos.create_metadata(hash)

      assert Photos.remove_reference(hash) == 0
    end

    test "errors for nonexistent hash" do
      hash = "1234567890abcdefg"
      assert_raise Ecto.NoResultsError, fn ->
        Photos.remove_reference(hash) == 0
      end
    end
  end
end

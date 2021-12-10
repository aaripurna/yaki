defmodule YakiCoreTest.CleanerTest do
  use ExUnit.Case, async: true
  doctest YakiCore.Cleaner
  alias YakiCore.Cleaner

  @file_path Path.absname("test/factory/images/macaca-nigra.jpg")
  @readme_path Path.absname("README.md")
  @mix_path Path.absname("mix.exs")
  @new_file_path Path.absname("test/factory/images/macaca-nigra-copy.jpg")

  describe "#is_media_file?(file_path)" do
    test "it returns true if the path is image" do
      assert Cleaner.is_media_file?(@file_path)
    end

    test "it returns false if the path is not media (README.md)" do
      assert Cleaner.is_media_file?(@readme_path) == false
    end

    test "it returns false if the path is elixir file (mix.exs)" do
      assert Cleaner.is_media_file?(@mix_path) == false
    end
  end

  describe "#delete(file_path)" do
    setup do
      File.cp!(@file_path, @new_file_path)
    end

    test "it deletes media file" do
      assert File.exists?(@new_file_path)
      assert Cleaner.delete(@new_file_path) == :ok
      assert File.exists?(@new_file_path) == false
    end

    test "it wont delete othe than media file (README.md)" do
      assert Cleaner.delete(@readme_path) == {:error, :not_found}
    end

    test "it wont delete elixir file (mix.exs)" do
      assert Cleaner.delete(@readme_path) == {:error, :not_found}
    end
  end
end

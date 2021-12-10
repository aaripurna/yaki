defmodule YakiCoreTest do
  use ExUnit.Case
  doctest YakiCore


  defmodule MyAdapter do
    @behaviour YakiCore.AdapterBase

    def save(%YakiCore.FileOne{} = file, name) do
      output = Map.get(file, :temp_variants)

      Map.put(file, :output, %YakiCore.FileOutputOne {
        adapter: name,
        variants: output
      })
    end
  end

  defmodule MyUploader do
    @file_path Path.absname("test/factory/images/macaca-nigra.jpg")

    use YakiCore
    adapter(:local, MyAdapter)
    default :local
    variants thug_life: {100, 100, resize_to: :fill}
    variants two_pac: {100, 100}

    def foo do
      variants()
    end

    def create do
      new(%YakiCore.RawFile{
        path: @file_path,
        filename: Path.basename(@file_path),
        content_type: "image/jpeg",
      })
      |> save
    end
  end

  describe "variant/2" do
    test "it adds new variant" do
      assert (MyUploader.foo() |> Enum.member?({:thug_life, {100, 100, [resize_to: :fill]}}) == true)
    end

    test "it adds empty args if none given" do
      assert (MyUploader.foo() |> Enum.member?({:two_pac, {100, 100, []}}) == true)
    end
  end

  describe "new/0" do
    test "it creates file with all of the variants" do
      assert (MyUploader.create() |> Map.get(:output)) != []
    end
  end
end

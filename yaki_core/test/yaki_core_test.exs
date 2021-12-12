defmodule YakiCoreTest do
  @file_path Path.absname("test/factory/images/macaca-nigra.jpg")
  @original_copy "/tmp/macaca-nigra.jpg"

  use ExUnit.Case
  doctest YakiCore

  setup do
    File.cp!(@file_path, @original_copy)
  end

  defmodule MyAdapter do
    @behaviour YakiCore.AdapterBase

    def save(%YakiCore.FileOne{} = file, opts) do
      output = Map.get(file, :temp_variants)
      name = Keyword.get(opts, :name)

      Map.put(file, :output, %YakiCore.FileOutputOne{
        adapter: name,
        variants: output
      })
    end
  end

  defmodule MyUploader do
    @file_path "/tmp/macaca-nigra.jpg"
    use YakiCore
    adapter(MyAdapter, storage: "uploads", name: :local)
    default(:local)

    variants(
      thug_life: {100, 100, resize_to: :fill},
      two_pac: {100, 100},
      thumbnail: {200, 300, [resize_to: :limit]}
    )

    def init(_any) do
      %YakiCore.RawFile{
        path: @file_path,
        filename: Path.basename(@file_path),
        content_type: "image/jpeg"
      }
    end
  end

  describe "adapter/1" do
    test "it adds one adapter" do
      assert MyUploader.adapters() == [
               {:local, [YakiCoreTest.MyAdapter, [storage: "uploads", name: :local]]}
             ]
    end
  end

  describe "variant/2" do
    test "it adds new variant" do
      assert MyUploader.variants() |> Enum.member?({:thug_life, {100, 100, [resize_to: :fill]}}) ==
               true
    end

    test "it adds empty args if none given" do
      assert MyUploader.variants() |> Enum.member?({:two_pac, {100, 100, []}}) == true
    end
  end

  describe "new/0" do
    test "it creates file with all of the variants" do
      result = MyUploader.create({})
      assert result |> Map.get(:output) != []
    end
  end
end

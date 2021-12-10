defmodule YakiCoreTest.TransformerTest do
  use ExUnit.Case, async: true
  doctest YakiCore.Transformer

  alias YakiCore.{Transformer, Variant, RawFile}

  @file_path Path.absname("test/factory/images/macaca-nigra.jpg")

  test "it can inspect the file information" do
    {variant, _} = Transformer.inspect(:original, %RawFile{
      path: @file_path,
      filename: "macaca-nigra.jpg",
      content_type: "image/jpeg",
    })

    assert Map.get(variant, :size) == {2641, 1760}
  end

  test "it allows to resize image" do
    {_, source} = Transformer.transform({%Variant{name: "thumbnail", size: {200, 100}}, %RawFile{
      path: @file_path,
      filename: "macaca-nigra.jpg",
      content_type: "image/jpeg",
    }})

    {variant, _} = Transformer.inspect(:thumbnail, %RawFile{
      path: source.path,
      filename: "macaca-nigra.jpg",
      content_type: "image/jpeg",
    })
    assert Map.get(variant, :size) == {200, 100}
  end

  test "it shows the file identity" do
    data = Transformer.file_identity(%RawFile{
      path: @file_path,
      filename: "macaca-nigra.jpg",
      content_type: "image/jpeg",
    })

    assert Map.get(data, :format) == "jpeg"
  end
end

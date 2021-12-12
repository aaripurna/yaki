defmodule YakiCoreTest.TransformerTest do
  use ExUnit.Case
  doctest YakiCore.Transformer

  alias YakiCore.{Transformer, Variant, RawFile}

  @file_path Path.absname("test/factory/images/macaca-nigra.jpg")
  @file_variant_path Path.absname("test/factory/images/macaca-nigra-variant.jpg")

  setup do
    on_exit(fn -> File.rm(@file_variant_path) end)
  end

  test "it can inspect the file information" do
    {variant, _} =
      Transformer.inspect(:original, %RawFile{
        path: @file_path,
        filename: "macaca-nigra.jpg",
        content_type: "image/jpeg"
      })

    assert Map.get(variant, :size) == {1200, 800}
  end

  test "it allows to resize image" do
    {_, source} =
      Transformer.transform(
        %Variant{name: "thumbnail", size: {200, 100}},
        %RawFile{
          path: @file_path,
          filename: "macaca-nigra.jpg",
          content_type: "image/jpeg"
        },
        path: @file_variant_path
      )

    {variant, _} =
      Transformer.inspect(:thumbnail, %RawFile{
        path: source.path,
        filename: "macaca-nigra.jpg",
        content_type: "image/jpeg"
      })

    assert Map.get(variant, :size) == {200, 100}
  end

  test "it supports resize_to_limit" do
    {_, source} =
      Transformer.transform(
        %Variant{name: "thumbnail", size: {200, 100}},
        %RawFile{
          path: @file_path,
          filename: "macaca-nigra.jpg",
          content_type: "image/jpeg"
        },
        resize_to: :limit,
        path: @file_variant_path
      )

    {variant, _} =
      Transformer.inspect(:thumbnail, %RawFile{
        path: source.path,
        filename: "macaca-nigra.jpg",
        content_type: "image/jpeg"
      })

    assert Map.get(variant, :size) == {div(2641 * 100, 1760), 100}
  end

  test "it supports resize to extent" do
    {_, source} =
      Transformer.transform(
        %Variant{name: "thumbnail", size: {500, 500}},
        %RawFile{
          path: @file_path,
          filename: "macaca-nigra.jpg",
          content_type: "image/jpeg"
        },
        resize_to: :extent,
        path: @file_variant_path
      )

    {variant, _} =
      Transformer.inspect(:thumbnail, %RawFile{
        path: source.path,
        filename: "macaca-nigra.jpg",
        content_type: "image/jpeg"
      })

    assert Map.get(variant, :size) == {500, 500}
  end

  test "it shows the file identity" do
    data =
      Transformer.file_identity(%RawFile{
        path: @file_path,
        filename: "macaca-nigra.jpg",
        content_type: "image/jpeg"
      })

    assert Map.get(data, :format) == "jpeg"
  end
end

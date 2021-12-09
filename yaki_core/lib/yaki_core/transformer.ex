defmodule YakiCore.Transformer do
  import Mogrify

  @spec transform({YakiCore.Variant.t(), YakiCore.RawFile.t()}) ::
          {YakiCore.Variant.t(), YakiCore.RawFile.t()}
  def transform({%YakiCore.Variant{size: {height, width}} = variant, %YakiCore.RawFile{} = source}) do
    file = open(source.path) |> resize_to_fill("#{height}x#{width}") |> save
    {variant, Map.put(source, :path, file.path)}
  end

  def inspect(name, %YakiCore.RawFile{} = source) do
    image = open(source.path) |> verbose
    {
      %YakiCore.Variant{
        name: name,
        size: {image.height, image.width}
      },
      source
    }
  end
end

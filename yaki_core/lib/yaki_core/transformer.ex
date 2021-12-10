defmodule YakiCore.Transformer do
  import Mogrify

  @spec transform({YakiCore.Variant.t(), YakiCore.RawFile.t()}) ::
          {YakiCore.Variant.t(), YakiCore.RawFile.t()}
  def transform(
        {%YakiCore.Variant{size: {height, width}} = variant, %YakiCore.RawFile{} = source}, opts \\ []
      ) do
    strategy = Keyword.get(opts, :resize_to, :fill)

    file = open(source.path) |> resize(strategy, "#{width}x#{height}") |> save

    {variant, Map.put(source, :path, file.path)}
  end

  def resize(image,:fill, size), do: resize_to_fill(image, size)
  def resize(image,:limit, size), do: resize_to_limit(image, size)
  def resize(image,:extent, size), do: resize_to_limit(image, size)

  def inspect(name, %YakiCore.RawFile{} = source) do
    image = open(source.path) |> verbose

    {
      %YakiCore.Variant{
        name: Atom.to_string(name),
        size: {image.height, image.width}
      },
      source
    }
  end

  def file_identity(%YakiCore.RawFile{} = source) do
    identify(source.path)
  end
end

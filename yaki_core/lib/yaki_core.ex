defmodule YakiCore do
  # @callback init(any()) :: any()

  alias YakiCore.Configuration

  @spec adapter(atom, module) :: :ok
  defmacro adapter(name, module) do
    Configuration.add_adapter({name, expand_alias(module, __CALLER__)})
  end

  @spec variants(list(YakiCore.Configuration.variant())) :: :ok
  defmacro variants(variants) do
    Enum.map(variants, fn {key, value} ->
      case value do
        {height, width} -> {key, {height, width, []}}
        {_, _, [height, width, opts]} -> {key, {height, width, opts}}
      end

    end)
     |> Configuration.set_variants()
  end

  defp expand_alias({:__aliases__, _, _} = alias, env), do: Macro.expand(alias, env)

  defp expand_alias(other, _env), do: other

  @spec default(atom) :: :ok
  defmacro default(name) do
    Configuration.set_default_adapter(name)
  end

  @spec new(YakiCore.RawFile.t()) :: YakiCore.FileOne.t()
  def new(%YakiCore.RawFile{} = source) do
    %YakiCore.FileOne {
      configuration: configuration(),
      source: source,
      temp_variants: [],
      output: nil
    }
      |> create_variant()
  end

  @spec save(YakiCore.FileOne.t()) :: YakiCore.FileOne.t()
  def save(%YakiCore.FileOne{} = file) do
    {name, adapter} = default_adapter()
    adapter.save(file, name)
  end

  def create_variant(%YakiCore.FileOne{} = file) do
    new_variants = Enum.map(variants(), fn {name, {height, width, opts}} ->
      {variant, result} = YakiCore.Transformer.transform(%YakiCore.Variant {
        name: name,
        size: {height, width}
      }, file.source, opts)

      %YakiCore.FileVariant{
        name: variant.name,
        filename: result.filename,
        path: result.path,
        content_type: result.content_type,
        options: {}
      }
    end)

    {variant, result} = YakiCore.Transformer.inspect(:original, file.source)

    original = %YakiCore.FileVariant{
                  name: variant.name,
                  filename: result.filename,
                  path: result.path,
                  content_type: result.content_type,
                  options: {}
                }
    Map.put(file, :temp_variants, [original | new_variants])
  end

  def remove_file(%YakiCore.FileVariant{} = file) do
    YakiCore.Cleaner.delete(file.path)
  end

  def rollback(%YakiCore.FileOne{} = file) do
    Enum.each(file.temp_variants, fn variant ->
      remove_file(variant.path)
    end)
  end

  @spec adapters :: keyword(module())
  def adapters do
    Configuration.adapters()
  end

  @spec default_adapter :: {atom(), module()}
  def default_adapter do
    Configuration.default_adapter()
  end

  def variants do
    Configuration.variants()
  end

  def configuration do
    %YakiCore.Configuration {
      adapters: adapters(),
      default_adapter: default_adapter(),
      variants: variants(),
    }
  end

  defmacro __using__(_opts) do
    quote do
      import YakiCore
      # @behaviour YakiCore
    end
  end
end

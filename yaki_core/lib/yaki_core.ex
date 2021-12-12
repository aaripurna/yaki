defmodule YakiCore do
  @callback init(any) :: YakiCore.RawFile.t()

  defmacro __using__(_opts) do
    quote do
      import YakiCore
      @behaviour YakiCore

      Module.register_attribute(__MODULE__, :adapters, accumulate: true)
      @variants []

      @before_compile unquote(__MODULE__)

      def configuration do
        %YakiCore.Configuration {
          adapters: adapters(),
          default_adapter: default_adapter(),
          variants: variants(),
        }
      end

      @spec new(YakiCore.RawFile.t()) :: YakiCore.FileOne.t()
      def new(%YakiCore.RawFile{} = source) do
        %YakiCore.FileOne {
          configuration: configuration(),
          source: source,
          temp_variants: [],
          output: nil
        }
          |> create_variant(variants())
      end

      @spec save(YakiCore.FileOne.t()) :: YakiCore.FileOne.t()
      def save(%YakiCore.FileOne{} = file) do
        {name, adapter} = default_adapter()
        adapter.save(file, name)
          |> remove_tmp()
      end

      def create(any) do
        init(any)
          |> new()
          |> save()
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def adapters do
        @adapters
      end

      def variants do
        @variants
      end

      def default_adapter do
        {@default_adapter, adapters() |> Keyword.get(@default_adapter)}
      end
    end
  end

  defmacro adapter(name, module) do
    module = expand_alias(module, __CALLER__)
    quote do
      @adapters {unquote(name), unquote(module)}
      :ok
    end
  end

  defmacro variants(args) do
    variants = Enum.map(args, fn {key, value} ->
      case value do
        {:{}, _, [height, width, opts]} -> {key, {height, width, opts}}
        {height, width} -> {key, {height, width, []}}
      end

    end) |> Macro.escape()

    quote do
      @variants unquote(variants)
      :ok
    end
  end

  defp expand_alias({:__aliases__, _, _} = alias, env), do: Macro.expand(alias, env)

  defp expand_alias(other, _env), do: other

  defmacro default(name) do
    quote do
      @default_adapter unquote(name)
      :ok
    end
  end
  def create_variant(%YakiCore.FileOne{} = file, variants) do
    new_variants = Enum.map(variants, fn {name, {height, width, opts}} ->
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

  def remove_tmp(%YakiCore.FileOne{} = file) do
    Enum.each(file.temp_variants, fn variant ->
      remove_file(variant)
    end)

    file
  end
end

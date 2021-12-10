defmodule YakiCore.Main do
  alias YakiCore.Configuration

  defmacro adapter(name, module) do
    Configuration.add_adapter({name, module})
  end

  @spec variants(list(YakiCore.Configuration.variant())) :: :ok
  defmacro variants(variants) do
    Configuration.set_variants(variants)
  end

  defmacro default(name) do
    Configuration.set_default_adapter(name)
  end

  def adapters do
    Configuration.adapters()
  end

  def default_adapter do
    Configuration.default_adapter()
  end

  def variants do
    Configuration.variants()
  end
end

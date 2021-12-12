defmodule YakiCore.FileOne do
  defstruct [:configuration, :source, :temp_variants, :output]

  @type t() :: %__MODULE__{
          configuration: YakiCore.Configuration.t(),
          source: YakiCore.RawFile.t(),
          temp_variants: list(YakiCore.FileVariant.t()),
          output: YakiCore.FileOutputOne.t() | nil
        }
end

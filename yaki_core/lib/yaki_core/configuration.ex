defmodule YakiCore.Configuration do
  @type variant() :: {atom(), {height :: integer(), width :: integer(), opts :: keyword()}}

  defstruct [:adapters, :default_adapter, :variants]

  @type t() :: %__MODULE__{
          adapters: list({atom(), module()}),
          default_adapter: {atom(), module()},
          variants: list(variant())
        }
end

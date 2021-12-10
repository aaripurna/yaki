defmodule YakiCore.AdapterBase do
  @callback save(file :: YakiCore.FileOne.t(), name :: String.t()) :: YakiCore.FileOne.t()
end

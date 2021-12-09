defmodule YakiCore.Variant do
  defstruct [:name, :size]

  @type t() :: %__MODULE__{
    name: String.t(),
    size: {height :: number(), width :: number()}
  }
end

defmodule YakiCore.RawFile do
  defstruct [:path, :filename, :content_type]

  @type t() :: %__MODULE__{
    path: String.t(),
    filename: String.t(),
    content_type: String.t(),
  }
end

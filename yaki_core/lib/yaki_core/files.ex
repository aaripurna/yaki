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
          content_type: String.t()
        }
end

defmodule YakiCore.FileVariant do
  defstruct [:name, :filename, :content_type, :path, :options]

  @type t() :: %__MODULE__{
    name: String.t(),
    filename: String.t(),
    content_type: String.t(),
    path: String.t(),
    options: any(),
  }
end

defmodule YakiCore.FileOutputOne do
  defstruct [:adapter, :variants]
  @type t() :: %__MODULE__{
    adapter: String.t(),
    variants: list(YakiCore.FileVariant.t())
  }
end

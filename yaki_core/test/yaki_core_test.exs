defmodule YakiCoreTest do
  use ExUnit.Case
  doctest YakiCore

  test "greets the world" do
    assert YakiCore.hello() == :world
  end
end

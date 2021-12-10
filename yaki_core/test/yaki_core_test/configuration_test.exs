defmodule YakiCore.ConfigurationTest do
  defmodule ExampleAdaptor do
  end

  defmodule AnotherExampleModule do
  end

  use ExUnit.Case

  doctest YakiCore.Configuration

  test "it allows to add adapter" do
    YakiCore.Configuration.add_adapter({:example, ExampleAdaptor})
    assert Enum.at(YakiCore.Configuration.adapters(), 0) == {:example, ExampleAdaptor}
  end

  test "it allows to set multiple adapters" do
    YakiCore.Configuration.add_adapter({:example, ExampleAdaptor})
    YakiCore.Configuration.add_adapter({:another, AnotherExampleModule})

    assert Enum.member?(YakiCore.Configuration.adapters(), {:example, ExampleAdaptor})
    assert Enum.member?(YakiCore.Configuration.adapters(), {:another, AnotherExampleModule})
  end

  test "it allows to set default adapter" do
    YakiCore.Configuration.add_adapter({:example, ExampleAdaptor})
    YakiCore.Configuration.add_adapter({:another, AnotherExampleModule})
    YakiCore.Configuration.set_default_adapter(:another)

    assert YakiCore.Configuration.default_adapter() == {:another, AnotherExampleModule}
  end

  test "it allows to set variants" do
    YakiCore.Configuration.set_variants(
      original: {400, 300, [resize_to: :fill]},
      cover: {800, 600},
      thumbnail: {100, 75}
    )

    assert(YakiCore.Configuration.variants() |> Enum.member?({:original, {400, 300, [resize_to: :fill]}}))
    assert(YakiCore.Configuration.variants() |> Enum.member?({:cover, {800, 600}}))
    assert(YakiCore.Configuration.variants() |> Enum.member?({:thumbnail, {100, 75}}))
  end

  test "add variant" do
    YakiCore.Configuration.add_variant({:example, {400, 400, [resize_to: :fill]}})
    assert(YakiCore.Configuration.variants() |> Enum.member?({:example, {400, 400, [resize_to: :fill]}}))
  end
end

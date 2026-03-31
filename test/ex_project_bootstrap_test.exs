defmodule ExProjectBootstrapTest do
  use ExUnit.Case
  doctest ExProjectBootstrap

  test "greets the world" do
    assert ExProjectBootstrap.hello() == :world
  end
end

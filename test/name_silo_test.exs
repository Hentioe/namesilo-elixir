defmodule NameSiloTest do
  use ExUnit.Case
  doctest NameSilo

  test "greets the world" do
    assert NameSilo.hello() == :world
  end
end

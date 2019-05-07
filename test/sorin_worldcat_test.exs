defmodule SorinWorldcatTest do
  use ExUnit.Case
  doctest SorinWorldcat

  test "greets the world" do
    assert SorinWorldcat.hello() == :world
  end
end

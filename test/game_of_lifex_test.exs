defmodule GameOfLifexTest do
  use ExUnit.Case
  doctest GameOfLifex

  test "greets the world" do
    assert GameOfLifex.hello() == :world
  end
end

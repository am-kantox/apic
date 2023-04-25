defmodule ApicTest do
  use ExUnit.Case
  doctest Apic

  test "greets the world" do
    assert Apic.hello() == :world
  end
end

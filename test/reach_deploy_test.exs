defmodule ReachDeployTest do
  use ExUnit.Case
  doctest ReachDeploy

  test "greets the world" do
    assert ReachDeploy.hello() == :world
  end
end

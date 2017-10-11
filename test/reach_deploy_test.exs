defmodule ReachDeployTest do
  use ExUnit.Case
  doctest ReachDeploy

  # Helper function for invoking a mix task.
  # Fails if tasks does not exists.
  def mix(task, args \\ []) do
    IO.puts "$ mix #{task}"
    assert {_, 0} = System.cmd("mix", [task | args],
      into: IO.stream(:stdio, :line))
  end

  test "deploy creates a init file" do
    mix "reach.deploy"

    assert File.exists? ".dockerignore"
  end

end
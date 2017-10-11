defmodule Mix.Tasks.Reach.Deploy do
  use Mix.Task

  @shortdoc "Deploys to Docker Swarm cloud"
  @moduledoc ~S"""
  Deploys the application to Swarm Cloud.

  ## Usage
  ```
    mix deploy
  ```
  """

  defdelegate run(args), to: ReachDeploy, as: :deploy
end
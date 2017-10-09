defmodule Mix.Tasks.Reach.Deploy do
  @moduledoc """
  Deploys the application to Swarm Cloud.

  ## Usage
      mix deploy
  """
  defdelegate run(args), to: ReachDeploy, as: :deploy
end
defmodule ReachDeploy do
  @moduledoc """
  This application is intended to ease the deploy process to Docker Swarm clusters of applications
  built with Elixir.
  """

  # Requires Logger for logging deploy process
  require Logger

  @dockerignore :code.priv_dir(:reach_deploy)

  @doc """
  Deploys the application to Swarm Cloud.

  ## Usage
      iex> mix deploy
  """
  def deploy(_args) do
    # file = Application.get_env(:reach_deploy, :docker_compose_file,
    # "docker-compose.yml")

    # Copy .dockerignore if not exists
    unless File.exists?(".dockerignore") do
      File.cp(Path.join(@dockerignore, "dockerignore"), ".dockerignore")
    end

    # # Builds the image
    # Mix.shell.info "Building the image..."
    # Mix.Task.run("docker.build")

    # # Releases a new version
    # Mix.shell.info "Releasing a new version..."
    # Mix.Task.run("docker.release")

    # # Ships to Docker Hub
    # Mix.shell.info "Shipping image to Docker Hub..."
    # Mix.Task.run("docker.shipit")

    # Creates a docker compose file
    unless File.exists?("docker-compose.template.yml") do
      Mix.shell.info "No `docker-compose.template.yml` file found. Aborting."
      System.halt(0)
    end

    Mix.shell.info "Generating a Docker Compose file based on template..."
    # Reads the file and generate a new one based on something
    # TODO: What's something?
    with {:ok, file} <- File.read("docker-compose.template.yml") do
      Regex.replace(~r/\{([a-zA-Z0-9]+)\}/, file, fn _, s -> tag_replace(s) end)
      |> IO.puts()
    end
  end

  defp tag_replace("image") do
    "docker-compose.yml"
  end

  defp tag_replace(any) do
    Logger.warn("Tag not defined: #{any}")
    any
  end

  # TODO: Run Mix Docker build/release
  # TODO: Create new docker-compose file based on configs from deploy.conf
  # TODO: Run Mix shipit
  # TODO: Deploy app to cluster
  # TODO: Do cleanups

end

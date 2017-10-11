defmodule ReachDeploy do
  @moduledoc """
  This application is intended to ease the deploy process to Docker Swarm clusters of applications
  built with Elixir.
  """

  # Requires Logger for logging deploy process
  require Logger

  alias Mix.{Releases.Release, Project}

  @dockerignore :code.priv_dir(:reach_deploy)
  @default_tag_template "{mix-version}.{git-count}-{git-sha}" # Needed to hardcode this... :(

  @doc """
  Deploys the application to Swarm Cloud.

  ## Usage
      mix deploy
  """
  def deploy(args) do

    env = task_env(args)

    stack_name = Application.get_env(:reach_deploy, :stack_name)

    # Copy .dockerignore if not exists
    unless File.exists?(".dockerignore") do
      Mix.shell.info ".dockerignore not found, creating it..."
      File.cp(Path.join(@dockerignore, "dockerignore"), ".dockerignore")
    end

    unless File.exists?(Path.join(["rel", "config.exs"])) do
      Mix.shell.info "Initial config file not found, creating it..."
      Mix.Task.run("docker.init")
    end

    # Builds the image
    Mix.shell.info "Building the image..."
    Mix.Task.run("docker.build")

    # Releases a new version
    Mix.shell.info "Releasing a new version..."
    Mix.Task.run("docker.release")

    # Ships to Docker Hub
    Mix.shell.info "Publishing image on Docker Hub..."
    Mix.Task.run("docker.publish", args)

    # Creates a docker compose file
    unless File.exists?("docker-compose.template." <> env <> ".yml") ||
      File.exists?("docker-compose.template.yml") do
        Mix.shell.error "No Docker Compose template file found. Aborting."
        System.halt(0)
    end

    Mix.shell.info "Generating a Docker Compose file based on template..."
    # Reads the file and generate a new one based on template
    with {:ok, file} <- File.read("docker-compose.template.yml") do
      contents = Regex.replace(~r/\{([a-zA-Z0-9]+)\}/, file, fn _, s ->
        tag_replace(s)
      end)

      # Dummy file
      unless File.exists? "docker-compose-#{stack_name}.yml" do
        :ok = File.write "docker-compose-#{stack_name}.yml",
        """
        version: "3.2"
        """
      end

      # Does the file write went ok?
      unless :ok === File.write "docker-compose.override.#{env}.yml", contents do
        Mix.shell.error "Could not create/update `docker-compose.override.#{env}.yml`. Aborting."
        System.halt(0)
      end
    end

    Mix.shell.info "Creating a brand new `deploy.conf` file based on configs..."
    create_deploy_config()

    Mix.shell.info "Deploying app to #{env} environment..."
    System.cmd("deploy", [env, "-n", "run"])
  end

  defp create_deploy_config() do
    contents =
    for {key, value} <- Application.get_env(:reach_deploy, :deploy_conf) do
      """
      [#{key}]
      user #{value[:user]}
      host #{value[:host]}
      compose_file docker-compose-#{get_stack_name()}.yml
      stack_name #{get_stack_name()}

      """
    end

    contents = contents
    |> to_string
    |> String.trim

    :ok = File.write "deploy.conf", contents
  end

  defp get_stack_name() do
    case Application.get_env(:reach_deploy, :stack_name) do
      nil ->
        Mix.shell.error "Config not set: :stack_name"
        System.halt(0)
      conf ->
        conf
    end
  end

  defp task_env(args) do
    {opts, _, _} = OptionParser.parse(args)
    if opts[:server] do
      opts[:server]
    else
      "prod"
    end
  end

  # Replaces tags found on `docker-compose-template.yml`
  defp tag_replace(string, opts \\ [])

  defp tag_replace("image", opts) do
    image(make_image_tag(opts[:tag]))
  end

  defp tag_replace(any, _) do
    Logger.warn("Tag not defined: #{any}")
    any
  end

  defp image(tag) do
    image_name() <> ":" <> to_string(tag)
  end

  defp image_name do
    Application.get_env(:mix_docker, :image) ||
      to_string(app_name())
  end

  defp make_image_tag(tag) do
    template = tag ||
      Application.get_env(:mix_docker, :tag) ||
      @default_tag_template
    Regex.replace(~r/\{([a-z0-9-]+)\}/, template, fn _, x -> tagvar(x) end)
  end

  defp tagvar("mix-version") do
    app_version() || tagvar("rel-version")
  end

  defp tagvar("rel-version") do
    release_version()
  end

  defp tagvar("git-sha"), do: tagvar("git-sha10")
  defp tagvar("git-sha" <> length) do
    {sha, 0} = System.cmd("git", ["rev-parse", "HEAD"])
    String.slice(sha, 0, String.to_integer(length))
  end

  defp tagvar("git-branch") do
    {branch, 0} = System.cmd("git", ["rev-parse", "--abbrev-ref", "HEAD"])
    String.trim(branch)
  end

  defp tagvar("git-count") do
    {count, 0} = System.cmd("git", ["rev-list", "--count", "HEAD"])
    String.trim(count)
  end

  defp tagvar(other) do
    raise "Image tag variable #{other} is not defined"
  end

  defp app_name do
    release_name_from_cwd = File.cwd! |> Path.basename |> String.replace("-", "_")
    Project.get.project[:app] || release_name_from_cwd
  end

  defp app_version do
    Project.get.project[:version]
  end

  defp release_version do
    {:ok, rel} = Release.get(:default)
    rel.version
  end

  # TODO: Deploy app to cluster
  # TODO: Do cleanups
end
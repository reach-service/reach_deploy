# Reach Deploy
## An Elixir package for deploying services to Reach Docker Swarm

This tool is intended to ease the deploy process of services wrote in Elixir to Docker Swarm clusters. It uses `mix docker` package to generate and publish the Docker image, and then uses the `deploy` script (available at https://github.com/reach-service/deployment-app) to deploy to cloud.

> Warning: this package is currently in alpha stage. Bugs and misbehaves are expected. If you find anything weird, please, [open an issue](https://github.com/reach-service/reach_deploy/issues).

## Installation

As a private package, we can't depend on it directly. We'll import directly from GitHub instead.

To import from GitHub (using a machine that does have access to this repo), add this to your `mix.exs` file:

```elixir
def deps do
[
  {:reach_deploy, git: "git@github.com:reach-service/reach_deploy.git", tag: "v0.1.0-alpha"}
]
end
```

Then, do a `mix deps.get` and you're good to go.

## Usage

In order to use this package, you need to do some setup first. In your `config.exs` (or similar) file, do the following:

```elixir
config :reach_deploy,
# First, configure a stack name to use in your Docker Swarm stack
  stack_name: "deploy_test",
# Now, configure each server separately. To only mandatory configuration is a `prod` server.
  deploy_conf: %{
    prod: %{
    # User to use on `prod` server
      user: "ubuntu",
    # Hostname/ip of it
      host: "10.0.0.1"
    },
    cd: %{
      user: "ubuntu",
      host: "10.0.0.2"
    }
  }

# You'll need to explicity configure the `mix_docker` package with some info...
config :mix_docker,
# The image that'll be uploaded
  image: "reach/reach_deploy",
# Tag naming
  tag: "{rel-version}-{git-sha}-{git-branch}"
```

After configuring the package, do a `mix reach.deploy` to deploy to `prod` server on default. To deploy to another server, pass its name to `-s` option, as follows:

```elixir
mix reach.deploy -s staging
```

... where `staging` is a existent entry on `:deploy_conf` config.

Check for any errors (like missing certificates, etc). And then, you're good to go! :)
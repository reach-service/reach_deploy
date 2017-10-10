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

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `reach_deploy` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:reach_deploy, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/reach_deploy](https://hexdocs.pm/reach_deploy).


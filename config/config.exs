# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :reach_deploy, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:reach_deploy, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#
config :reach_deploy,
  stack_name: "deploy_test",
  deploy_conf: %{
    prod: %{
      user: "ubuntu",
      host: "34.234.135.157"
    },
    cd: %{
      user: "ubuntu",
      host: "34.236.72.71"
    }
  }

config :mix_docker,
  image: "reach/reach_deploy",
  tag: "{rel-version}-{git-branch}-{git-sha}"

# Removes warns for missing Distillery. Inception. o.O
config :distillery,
  no_warn_missing: [:distillery]

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

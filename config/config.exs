# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :discuss_it,
  ecto_repos: [DiscussIt.Repo]

# Configures the endpoint
config :discuss_it, DiscussItWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "N3psUr9mNvpnnaj8Jm2r07aV3BN7XhG2+TTzLdHyNc0hwECSzBfdbU/X3JspmRtj",
  render_errors: [view: DiscussItWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: DiscussIt.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

defmodule EdmBackend.Mixfile do
  use Mix.Project

  def project do
    [app: :edm_backend,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [coveralls: :test]]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {EdmBackend, []},
     applications: [
       :calendar,
       :flasked,
       :phoenix,
       :phoenix_pubsub,
       :phoenix_html,
       :cowboy,
       :logger,
       :gettext,
       :phoenix_ecto,
       :postgrex,
       :absinthe_plug,
       :absinthe_relay,
       :oauth,
       :ueberauth,
       :ueberauth_google,
       :ueberauth_edm,
       :guardian,
       :guardian_db]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2.0"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.0"},
     {:postgrex, ">= 0.11.2"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.11"},
     {:cowboy, "~> 1.0"},
     {:excoveralls, "~> 0.5", only: :test},

     # OAuth support
     {:oauth, github: "tim/erlang-oauth"},
     {:ueberauth, "~> 0.3"},
     {:ueberauth_google, "~> 0.3"},
     {:ueberauth_edm, git: "https://github.com/mytardis/ueberauth_edm.git"},
     {:guardian, "~> 0.12.0"},
     {:guardian_db, "~> 0.7"},

     # GraphQL support
     {:absinthe_plug, "~> 1.1"},
     {:absinthe_relay, "~> 0.9.4"},
     {:poison, "~> 2.1.0"},
     {:cors_plug, "~> 1.1"}, # Needed for cross-site access
     {:calendar, "~> 0.16.1"},
     {:calecto, "~> 0.16.0"},

     # Watch configured tasks
     {:eye_drops, "~> 1.2"},

     # Provides environment-based configuration
     {:flasked, "~> 0.4"}]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end

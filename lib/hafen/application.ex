defmodule Hafen.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Hafen.Repo,
      # Start the Telemetry supervisor
      HafenWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Hafen.PubSub},
      # Start the Endpoint (http/https)
      HafenWeb.Endpoint
      # Start a worker by calling: Hafen.Worker.start_link(arg)
      # {Hafen.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hafen.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    HafenWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

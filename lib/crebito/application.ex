defmodule Crebito.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Crebito.KV, name: Crebito.KV},
      Crebito.Repo,
      {DNSCluster, query: Application.get_env(:crebito, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Crebito.PubSub},
      # Start a worker by calling: Crebito.Worker.start_link(arg)
      # {Crebito.Worker, arg},
      # Start to serve requests, typically the last entry
      CrebitoWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Crebito.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CrebitoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

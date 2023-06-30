defmodule WhereTZ.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    Logger.info("WhereTZ Start")
    # :ok = :mnesia.create_schema([])
    :ok = :mnesia.start()
    WhereTZ.Init.run()

    # List all child processes to be supervised
    children = []

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Messenger.Supervisor]

    Logger.info("WhereTZ Started")
    Supervisor.start_link(children, opts)
  end
end


# WhereTZ.get(50.25, -107.80135)

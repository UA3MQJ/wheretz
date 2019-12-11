defmodule WhereTZ.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    Logger.info "WhereTZ Start"
    Logger.info "WhereTZ wait mnesia tables"
    local_tables = :mnesia.system_info(:local_tables)

    case :geo in local_tables do
      true ->
        :ok
      false ->
        Logger.error "Database is empty. Download database `mix download_data`"
        throw(:database_is_empty)
    end

    :mnesia.wait_for_tables([:geo], 10_000)
    Logger.info "WhereTZ Mnesia started"

    # List all child processes to be supervised
    children = []

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Messenger.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

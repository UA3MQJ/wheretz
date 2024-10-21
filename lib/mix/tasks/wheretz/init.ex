defmodule Mix.Tasks.WhereTz.Init do
  use Mix.Task
  require Logger

  @shortdoc "Download geojson data"
  def run(_) do
    WhereTZ.Init.run()

    if Mix.env() != :test do
      WhereTZ.Init.graceful_stop_database()
    end
  end

end

defmodule Mix.Tasks.WhereTz.Init do
  use Mix.Task
  require Logger

  @shortdoc "Download geojson data"
  def run(_) do
    WhereTZ.Init.run()
  end

end

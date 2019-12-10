defmodule Mix.Tasks.UnzipData do
  use Mix.Task
  require Logger

  @shortdoc "Unzip geojson files"
  def run(_) do
    Logger.debug @shortdoc

    :zip.extract('./priv/data.zip')
  end
end
defmodule Mix.Tasks.UnzipData do
  use Mix.Task
  require Logger

  @shortdoc "Unzip geojson files"
  def run(_) do
      Logger.debug @shortdoc
  end
end
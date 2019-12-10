defmodule Mix.Tasks.ZipData do
  use Mix.Task
  require Logger

  @shortdoc "Zip geojson files"
  def run(_) do
    Logger.debug @shortdoc
    path = "./priv/data/"
    files = File.ls!(path)
    |> Enum.map(fn filename -> Path.join(path, filename) end)
    |> Enum.map(&String.to_charlist/1)

    :zip.create('data.zip', files)
  end
end
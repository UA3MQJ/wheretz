defmodule Mix.Tasks.ZipData do
  use Mix.Task
  require Logger

  @shortdoc "Zip geojson files"
  def run(_) do
    Logger.debug @shortdoc

    files = Path.wildcard("./priv/data/*.geojson")
      |> Enum.map(&String.to_charlist/1)

    :zip.create('./priv/data.zip', files)

    files
      |> Enum.map(&File.rm!/1)
  end
end
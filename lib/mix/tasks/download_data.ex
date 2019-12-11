defmodule Mix.Tasks.DownloadData do
  use Mix.Task
  require Logger

  @shortdoc "Download geojson data"
  def run(_) do
    Logger.info @shortdoc
    download_data()
  end

  def download_data() do
    create_database()
    download_database()
  end

  def download_database() do
    :ssl.start() 
    :inets.start()
    

    link = 'https://github.com/evansiroky/timezone-boundary-builder/releases/download/2019b/timezones-with-oceans.geojson.zip'
    Logger.info "Download #{inspect link}"
    {:ok, :saved_to_file} = :httpc.request(:get, {link, []}, [], [stream: 'priv/data/timezones-with-oceans.geojson.zip'])
    Logger.info "Unzip"
    :zip.unzip('priv/data/timezones-with-oceans.geojson.zip',  [{:cwd, 'priv/data/'}])

    {:ok, file} = File.open("priv/data/dist/combined-with-oceans.json", [:read])
    json = IO.binread(file, :all)
    File.close(file)
    Logger.info "Readed json"

    data = Jason.decode!(json)
    Logger.info "Decoded json"

    data["features"]
      |> Enum.map(&parse_item/1)
      |> Enum.map(&insert_item/1)

    :mnesia.sync_log()
    :mnesia.stop()
  end

  def create_database() do
    :mnesia.stop()
    :mnesia.create_schema([node()])
    :mnesia.start()
    :mnesia.create_table(:geo,[{:disc_copies,[node()]},
                               {:attributes,[:zone_name, :minx, :maxx, :miny, :maxy, :geo_object]}])

    :mnesia.add_table_index(:geo, :minx)
    :mnesia.add_table_index(:geo, :maxx)
    :mnesia.add_table_index(:geo, :miny)
    :mnesia.add_table_index(:geo, :maxy)
  end

  def parse_item(item) do
    {minx, maxx, miny, maxy} = bounding_box(item["geometry"])
    zone_name = item["properties"]["tzid"]
    geo_object = item |> Geo.JSON.decode!()
    {zone_name, minx, maxx, miny, maxy, geo_object}
  end

  def insert_item(item) do
    {zone_name, minx, maxx, miny, maxy, geo_object} = item
    Logger.info "Add zone #{inspect zone_name}"
    :mnesia.dirty_write({:geo, zone_name, minx, maxx, miny, maxy, geo_object})
  end

  def bounding_box(%{"type" => "Polygon"} = geometry),
    do: bounding_box(geometry, :polygon)
  def bounding_box(%{"type" => "MultiPolygon"} = geometry),
    do: bounding_box(geometry, :multi_polygon)
  
  def bounding_box(geometry, :polygon) do
    li = geometry["coordinates"]
      |> Enum.reduce([], &(&1 ++ &2))

    [minx, _] = Enum.min_by(li, fn([x, _y]) -> x end)
    [maxx, _] = Enum.max_by(li, fn([x, _y]) -> x end)
    [_, miny] = Enum.min_by(li, fn([_x, y]) -> y end)
    [_, maxy] = Enum.max_by(li, fn([_x, y]) -> y end)

    {minx, maxx, miny, maxy}
  end
  def bounding_box(geometry, :multi_polygon) do
    li = geometry["coordinates"]
      |> Enum.reduce([], &(&1 ++ &2))
      |> Enum.reduce([], &(&1 ++ &2))

    [minx, _] = Enum.min_by(li, fn([x, _y]) -> x end)
    [maxx, _] = Enum.max_by(li, fn([x, _y]) -> x end)
    [_, miny] = Enum.min_by(li, fn([_x, y]) -> y end)
    [_, maxy] = Enum.max_by(li, fn([_x, y]) -> y end)

    {minx, maxx, miny, maxy}
  end

end
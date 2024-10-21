defmodule WhereTZ.Init do
  require Logger

  def run() do
    Logger.info("WhereTZ.Init")
    :mnesia.start()
    already_exists = :geo in :mnesia.system_info(:local_tables)
    if !already_exists do
      WhereTZ.Init.create_database()
      WhereTZ.Init.download_data()
      WhereTZ.Init.load_from_json()
    end
  end

  def create_database() do
    Logger.info("Setting up database")

    :mnesia.stop()
    :mnesia.create_schema([node() | Node.list()])
    :mnesia.start()

    {:atomic, :ok} = :mnesia.create_table(:geo, [
      disc_copies: [node()],
      attributes: [:zone_name, :minx, :maxx, :miny, :maxy, :geo_object]
    ])

    :mnesia.add_table_index(:geo, :minx)
    :mnesia.add_table_index(:geo, :maxx)
    :mnesia.add_table_index(:geo, :miny)
    :mnesia.add_table_index(:geo, :maxy)
  end

  def download_data() do
    Application.ensure_all_started(:httpoison)
    priv_data_path = Application.app_dir(:wheretz, "priv/data")
    Logger.info("priv_data_path =#{inspect(priv_data_path)}")
    File.mkdir(priv_data_path)

    link =
      "https://github.com/evansiroky/timezone-boundary-builder/releases/download/2023b/timezones-with-oceans.geojson.zip"

    Logger.info("Download #{inspect(link)} ...")
    %HTTPoison.Response{body: body} = HTTPoison.get!(link, [], follow_redirect: true)
    Logger.info("Save to file")
    File.write!(priv_data_path <> "/timezones-with-oceans.geojson.zip", body)

    Logger.info("Unzip ...")

    :zip.unzip(String.to_charlist(priv_data_path) ++ '/timezones-with-oceans.geojson.zip', [
      {:cwd, String.to_charlist(priv_data_path)}
    ])
  end

  def load_from_json() do
    Logger.info("Parsing & inserting json ...")
    priv_data_path = Application.app_dir(:wheretz, "priv/data")

    File.stream!(priv_data_path <> "/combined-with-oceans.json", [], 5120)
    |> Jaxon.Stream.from_enumerable()
    |> Jaxon.Stream.query([:root, "features", :all])
    |> Stream.map(&parse_item/1)
    |> Stream.map(&insert_item/1)
    |> Stream.run()

    Logger.info("Ready")
  end

  def graceful_stop_database() do
    Logger.info("Sync to disk")
    :mnesia.sync_log()
    :mnesia.stop()
    Logger.info("Mnesia stop")
  end

  def parse_item(item) do
    {minx, maxx, miny, maxy} = bounding_box(item["geometry"])
    zone_name = item["properties"]["tzid"]
    geo_object = item |> Geo.JSON.decode!()
    {zone_name, minx, maxx, miny, maxy, geo_object}
  end

  def insert_item(item) do
    {zone_name, minx, maxx, miny, maxy, geo_object} = item
    # Logger.info("Add zone #{inspect(zone_name)}")
    :mnesia.dirty_write({:geo, zone_name, minx, maxx, miny, maxy, geo_object})
  end

  def bounding_box(%{"type" => "Polygon"} = geometry),
    do: bounding_box(geometry, :polygon)

  def bounding_box(%{"type" => "MultiPolygon"} = geometry),
    do: bounding_box(geometry, :multi_polygon)

  def bounding_box(geometry, :polygon) do
    li =
      geometry["coordinates"]
      |> Enum.reduce([], &(&1 ++ &2))

    [minx, _] = Enum.min_by(li, fn [x, _y] -> x end)
    [maxx, _] = Enum.max_by(li, fn [x, _y] -> x end)
    [_, miny] = Enum.min_by(li, fn [_x, y] -> y end)
    [_, maxy] = Enum.max_by(li, fn [_x, y] -> y end)

    {minx, maxx, miny, maxy}
  end

  def bounding_box(geometry, :multi_polygon) do
    li =
      geometry["coordinates"]
      |> Enum.reduce([], &(&1 ++ &2))
      |> Enum.reduce([], &(&1 ++ &2))

    [minx, _] = Enum.min_by(li, fn [x, _y] -> x end)
    [maxx, _] = Enum.max_by(li, fn [x, _y] -> x end)
    [_, miny] = Enum.min_by(li, fn [_x, y] -> y end)
    [_, maxy] = Enum.max_by(li, fn [_x, y] -> y end)

    {minx, maxx, miny, maxy}
  end

end

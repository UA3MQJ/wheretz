defmodule Mix.Tasks.DownloadData do
  use Mix.Task
  require Logger

  @shortdoc "Download geojson data"
  def run(_) do
    Logger.info @shortdoc
    download_data()
  end

  def download_data() do
    # create_database()
    download_database()
    # load_from_json()
    # graceful_stop_database()
  end

  def create_database() do
    :mnesia.create_schema([])
    :mnesia.start()

    :mnesia.create_table(:geo,[{:ram_copies,[node()]},
                               {:attributes,[:zone_name, :minx, :maxx, :miny, :maxy, :geo_object]}])

    :mnesia.add_table_index(:geo, :minx)
    :mnesia.add_table_index(:geo, :maxx)
    :mnesia.add_table_index(:geo, :miny)
    :mnesia.add_table_index(:geo, :maxy)
  end


  def download_database() do
    Application.ensure_all_started :httpoison
    priv_data_path = Application.app_dir(:wheretz, "priv/data")
    Logger.info "priv_data_path =#{inspect priv_data_path}"
    File.mkdir(priv_data_path)

    link = "https://github.com/evansiroky/timezone-boundary-builder/archive/refs/tags/2023b.zip"

    Logger.info "Download #{inspect link} ..."
    %HTTPoison.Response{body: body} = HTTPoison.get!(link, [], [follow_redirect: true])
    Logger.info "Save to file"
    File.write!(priv_data_path <> "/timezones-with-oceans.geojson.zip", body)

    Logger.info "Unzip ..."
    :zip.unzip(String.to_charlist(priv_data_path) ++ '/timezones-with-oceans.geojson.zip',  [{:cwd, String.to_charlist(priv_data_path)}])

    Logger.info "Copy ..."
    File.cp("#{priv_data_path}" <> "/timezone-boundary-builder-2023b/timezones.json", "#{priv_data_path}" <> "/timezones.json")
  end

  def load_from_json() do
    priv_data_path = Application.app_dir(:wheretz, "priv/data")
    Logger.info "Read json ..." <> priv_data_path <> "/timezones.json"
    {:ok, file} = File.open(priv_data_path <> "/timezones.json", [:read])
    json = IO.binread(file, :all)
    File.close(file)

    Logger.info "Decode json ..."
    data = Jason.decode!(json)


    Logger.info "Parse and insert ..."
    data
      # |> Enum.map(&parse_item/1)
    #   |> Enum.map(&insert_item/1)

    # Logger.info "Ready"
  end

  def graceful_stop_database() do
    :mnesia.sync_log()
    :mnesia.stop()
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

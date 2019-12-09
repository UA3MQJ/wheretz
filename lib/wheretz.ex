defmodule WhereTZ do
  @moduledoc """
  Documentation for Wheretz.
  """
  @basename "priv/data/"

  require Logger

  # Time zone name by coordinates.
  #
  # @param lat Latitude (floating point number)
  # @param lng Longitude (floating point number)
  #
  # @return {String, nil, Array<String>} time zone name, or `nil` if no time zone corresponds
  #   to (lat, lng); in rare (yet existing) cases of ambiguous timezones may return an array of names
  def lookup(lat, lng) do
    candidates = Path.wildcard(@basename <> "*.geojson")
      |> Enum.map(&(Path.basename(&1)))
      |> Enum.map(fn(base_name) ->
        name = hd(String.split(base_name, ".geojson"))
        [zone | coords] = String.split(name, "__")
        zone = zone |> String.split("-") |> Enum.join("/")
        [minx, maxx, miny, maxy] = Enum.map(coords, &(String.to_float(&1)))
        {base_name, zone, minx, maxx, miny, maxy}
      end)
      |> Enum.filter(fn({_base_name, _zone, minx, maxx, miny, maxy}) ->
        lat >= miny and lat <= maxy and lng >= minx and lng <= maxx
      end)

    cond do
      length(candidates) == 0 ->
        nil
      length(candidates) == 1 -> 
        {_base_name, zone, _minx, _maxx, _miny, _maxy} = hd(candidates)
        zone
      true ->
        lookup_geo(lat, lng, candidates)
          |> simplify_result()
    end
  end

  # Timex.TimezoneInfo bject by coordinates.
  # @param lat Latitude (floating point number)
  # @param lng Longitude (floating point number)
  def get(lat, lng) do
    lookup(lat, lng)
      |> to_timezone()
  end

  defp to_timezone(zone) when is_bitstring(zone) do
    to_timezone([zone])
  end
  defp to_timezone(zone) when is_list(zone) do
    zone
      |> Enum.map(&(Timex.Timezone.get(&1)))
      |> Enum.reject(&(&1==nil))
      |> simplify_result()
  end
  defp to_timezone(_), do: nil

  defp simplify_result([]),     do: nil
  defp simplify_result([item]), do: item
  defp simplify_result(items),  do: items

  defp lookup_geo(lat, lng, candidates) do
    candidates
      |> Enum.filter(fn({fname, _, _, _, _, _}) ->
        {:ok, file} = File.open("./priv/data/" <> fname, [:read])
        json = IO.binread(file, :all)
        File.close(file)
        data =  Geo.JSON.decode!(Poison.decode!(json))
        Topo.contains?(hd(data.geometries), %Geo.Point{ coordinates: {lng, lat}})
      end)
      |> Enum.map(fn({_base_name, zone, _minx, _maxx, _miny, _maxy}) -> zone end)
  end

end

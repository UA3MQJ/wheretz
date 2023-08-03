defmodule WhereTZ do
  @moduledoc """
  **WhereTZ** is Elixir version of Ruby gem for lookup of timezone by georgraphic coordinates.

  ## Example

      iex(1)> WhereTZ.lookup(50.004444, 36.231389)  
      "Europe/Kiev"

      iex(2)> WhereTZ.get(50.004444, 36.231389)   
      #<TimezoneInfo(Europe/Kiev - EET (+02:00:00))>
  """

  require Logger

  @doc """
  Time zone name by coordinates.

    - lat Latitude (floating point number)
    - lng Longitude (floating point number)

  @return {String, nil, Array<String>} time zone name, or `nil` if no time zone corresponds
    to (lat, lng); in rare (yet existing) cases of ambiguous timezones may return an array of names

  ## Example

      iex(1)> WhereTZ.lookup(50.004444, 36.231389)  
      "Europe/Kiev"
  """
  @spec lookup(-90..90, -180..180) :: String.t() | nil
  def lookup(lat, lng) do
    # where = :ets.fun2ms(fn({:geo, zone_name, minx, maxx, miny, maxy, geo_object}) when lng>=minx and lng<=maxx and lat>=miny and lat<=maxy -> {zone_name, geo_object} end)
    where = [
      {{:geo, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6"},
       [
         {:andalso,
          {:andalso, {:andalso, {:>=, {:const, lng}, :"$2"}, {:"=<", {:const, lng}, :"$3"}},
           {:>=, {:const, lat}, :"$4"}}, {:"=<", {:const, lat}, :"$5"}}
       ], [{{:"$1", :"$6"}}]}
    ]

    {:atomic, candidates} = :mnesia.transaction(fn -> :mnesia.select(:geo, where) end)

    cond do
      length(candidates) == 0 ->
        nil

      length(candidates) == 1 ->
        {zone_name, _geo_object} = hd(candidates)
        zone_name

      true ->
        lookup_geo(lat, lng, candidates)
        |> simplify_result()
    end
  end

  @doc """
  Timex.TimezoneInfo object by coordinates.
    - lat Latitude (floating point number)
    - lng Longitude (floating point number)

  @return Timex.TimezoneInfo

  ## Example

      iex(1)> WhereTZ.get(50.004444, 36.231389)   
      #<TimezoneInfo(Europe/Kiev - EET (+02:00:00))>
  """
  @spec get(-90..90, -180..180) :: Timex.TimezoneInfo.t() | nil
  def get(lat, lng) do
    lookup(lat, lng)
    |> to_timezone()
  end

  defp to_timezone(zone) when is_bitstring(zone) do
    to_timezone([zone])
  end

  defp to_timezone(zone) when is_list(zone) do
    zone
    |> Enum.map(&Timex.Timezone.get(&1))
    |> Enum.reject(&(&1 == nil))
    |> simplify_result()
  end

  defp to_timezone(_), do: nil

  defp simplify_result([]), do: nil
  defp simplify_result([item]), do: item
  defp simplify_result(items), do: items

  defp lookup_geo(lat, lng, candidates) do
    candidates
    |> Enum.filter(fn {_zone_name, geo_object} ->
      Topo.contains?(geo_object, %Geo.Point{coordinates: {lng, lat}})
    end)
    |> Enum.map(fn {zone_name, _geo_object} -> zone_name end)
  end
end

# WhereTZ: timezone lookup
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://travis-ci.org/UA3MQJ/wheretz.svg?branch=master)](https://travis-ci.org/UA3MQJ/wheretz?branch=master)
[![Coverage Status](https://coveralls.io/repos/github/UA3MQJ/wheretz/badge.svg?branch=master)](https://coveralls.io/github/UA3MQJ/wheretz?branch=master)
[![Inline docs](http://inch-ci.org/github/UA3MQJ/wheretz.svg)](http://inch-ci.org/github/UA3MQJ/wheretz)

**WhereTZ** is elixir version of Ruby gem for lookup of timezone by georgraphic coordinates.

https://github.com/zverok/wheretz

Features:

* no calls to external services, works without Internet connection;
* Timezone result is [%Timex.TimezoneInfo](https://hexdocs.pm/timex/Timex.TimezoneInfo.html#t:t/0)

## Usage

Add to project from hex.pm

```elixir
def deps do
  [
    {:wheretz, "~> 0.1.0"},
  ]
end
```

or from github

```elixir
def deps do
  [
    {:wheretz, git: "git@github.com:UA3MQJ/wheretz.git", tag: "v0.1.0"},
  ]
end
```

usage

```elixir
iex(1)> WhereTZ.get(50.004444, 36.231389)   
#<TimezoneInfo(Europe/Kiev - EET (+02:00:00))>
iex(2)> WhereTZ.lookup(50.004444, 36.231389)  
"Europe/Kiev"
```

## How it works

1. Latest version of [timezone-boundary-builder](https://github.com/evansiroky/timezone-boundary-builder) dataset is converted into ~400 `data/*.geojson` files;
2. Each of those files corresponds to one timezone; filename contains
  timezone name and _bounding box_ (min and max latitude and longitude);
3. On each lookup `WhereTZ` first checks provided coordinates by bounding
  boxes, and if only one bbox (extracted from filename) corresponds to
  them, returns timezone name immediately;
4. If there's several intersecting bounding boxes, `WhereTZ` reads only
  relevant timezone files (which are not very large) and checks which
  polygon actually contains the point.

## Known problems

* On "bounding box only" check, some points deeply in sea (and actually
  belonging to no timezone polygon) can be wrongly guessed as belonging
  to some timezone;

# Рецепты

```elixir
Moscow
WhereTZ.lookup(55.75, 37.616667) 

point = %Geo.Point{ coordinates: {55.75, 37.616667}}

{:ok, file} = File.open("./priv/data/Europe-Moscow__26.4402__69.9572__41.1851__82.0586.geojson", [:read])
json1 = IO.binread(file, :all)
File.close(file)
data1 = Jason.decode!(json1) |> Geo.JSON.decode!()


paris
WhereTZ.lookup(43.6605555555556, 7.2175)
point = %Geo.Point{ coordinates: {43.6605555555556, 7.2175}}

Kharkiv
WhereTZ.lookup(50.004444, 36.231389) 

{:ok, file} = File.open("./priv/data/Europe-Kiev__22.6408__40.2276__45.0532__52.3791.geojson", [:read])
json1 = IO.binread(file, :all)
File.close(file)

{:ok, file} = File.open("./priv/data/Europe-Moscow__26.4402__69.9572__41.1851__82.0586.geojson", [:read])
json2 = IO.binread(file, :all)
File.close(file)

data1 = Jason.decode!(json1) |> Geo.JSON.decode!()
data2 = Jason.decode!(json2) |> Geo.JSON.decode!()

point = %Geo.Point{ coordinates: {36.231389, 50.004444}}




WhereTZ.lookup(50.28337, -107.80135)
point = %Geo.Point{ coordinates: {-107.80135, 50.28337}}

{:ok, file} = File.open("./priv/data/America-Regina__-110.0064__-101.3619__48.9988__59.9998.geojson", [:read])
json1 = IO.binread(file, :all)
File.close(file)

{:ok, file} = File.open("./priv/data/America-Swift_Current__-107.8381__-107.7563__50.2588__50.3246.geojson", [:read])
json2 = IO.binread(file, :all)
File.close(file)

data1 = Jason.decode!(json1) |> Geo.JSON.decode!()
data2 = Jason.decode!(json2) |> Geo.JSON.decode!()
```



# WhereTZ: timezone lookup
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Hex.pm Version](http://img.shields.io/hexpm/v/wheretz.svg?style=flat)](https://hex.pm/packages/wheretz)
[![Coverage Status](https://coveralls.io/repos/github/UA3MQJ/wheretz/badge.svg?branch=master)](https://coveralls.io/github/UA3MQJ/wheretz?branch=master)
[![Inline docs](http://inch-ci.org/github/UA3MQJ/wheretz.svg)](http://inch-ci.org/github/UA3MQJ/wheretz)

**WARNING**

Not work in 2023 :(

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
    {:wheretz, "~> 0.1.16"},
  ]
end
```

or from github

```elixir
def deps do
  [
    {:wheretz, git: "git@github.com:UA3MQJ/wheretz.git", tag: "v0.1.16"},
  ]
end
```

Before the first start, you need to download the geo database.

```elixir
mix download_data
```

usage

```elixir
iex(1)> WhereTZ.get(50.004444, 36.231389)   
#<TimezoneInfo(Europe/Kiev - EET (+02:00:00))>
iex(2)> WhereTZ.lookup(50.004444, 36.231389)  
"Europe/Kiev"
```

## How it works

1. Latest version of [timezone-boundary-builder](https://github.com/evansiroky/timezone-boundary-builder) dataset is converted into mnesia table (125Mb);
2. For each time zone, store timezone name, geo polygon and calculate _bounding box_ (min and max latitude and longitude);
3. On each lookup `WhereTZ` first checks provided coordinates by bounding
  boxes, and if only one bbox, corresponds to them, returns timezone name immediately;
4. If there's several intersecting bounding boxes, `WhereTZ` checks which
  polygon actually contains the point.

## Known problems

* Not work with new format of geo data 2023

## Author

Alexey Bolshakov

## Thanks to

[Victor Shepelev](http://zverok.github.io/)

## License

Data license is [ODbL](https://opendatacommons.org/licenses/odbl/).

Code license is usual MIT.

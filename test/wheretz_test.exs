defmodule WheretzTest do
  use ExUnit.Case

  require Logger

  test "when unambiguous bounding box: Moscow" do
    assert WhereTZ.get(55.75, 37.616667) == Timex.Timezone.get("Europe/Moscow")
    assert WhereTZ.lookup(55.75, 37.616667) == "Europe/Moscow"
  end

  test "when ambiguous bounding box: Kharkiv" do
    assert WhereTZ.get(50.004444, 36.231389) == Timex.Timezone.get("Europe/Kiev")
    assert WhereTZ.lookup(50.004444, 36.231389) == "Europe/Kiev"
  end

  test "when edge case" do
    assert WhereTZ.get(43.6605555555556, 7.2175) == Timex.Timezone.get("Europe/Paris")
    assert WhereTZ.lookup(43.6605555555556, 7.2175) == "Europe/Paris"
  end

  test "when no timezone: middle of the ocean" do
    assert WhereTZ.get(35.024992, -39.481339) == nil
    assert WhereTZ.lookup(35.024992, -39.481339) == nil
  end

  test "when ambiguous timezones" do
    # i dont know why, but two zones ['America/Regina', 'America/Swift_Current'] not detect
    assert WhereTZ.get(50.28337, -107.80135) == Timex.Timezone.get("America/Swift_Current")
    assert WhereTZ.get(50.25, -107.80135) == Timex.Timezone.get("America/Regina")
    assert WhereTZ.lookup(50.25, -107.80135) == "America/Regina"
  end

end

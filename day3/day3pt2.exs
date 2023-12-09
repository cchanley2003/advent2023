defmodule RangeExpander do
  def expand_ranges(tuple) do
    tuple
    |> Enum.flat_map(fn {number, y, x_start, x_end} ->
      for x <- x_start..x_end, do: {number, y, x}
    end)
  end
end

defmodule Day3Pt22 do
  def process_file(file_path) do
  nums = File.stream!(file_path)
  |> Enum.with_index()
  |> Enum.map(fn {line, index} ->
    Regex.scan(~r/\d+/, line, return: :index)
    |> List.flatten()
    |> Enum.map(fn {start, _end} -> {start, start+_end-1} end)
    |> Enum.map(fn {start, _end} -> { String.slice(line, start.._end) |> String.to_integer(), index, start, _end} end)
    end)
  |> Enum.reject(fn l -> length(l) < 1 end)
  |> Enum.flat_map(&RangeExpander.expand_ranges/1)
  |> Enum.reduce(%{}, fn {number, y, x}, acc ->
    Map.put(acc, {y, x}, number)
    end)
  |> IO.inspect()


  gears = File.stream!(file_path)
  |> Enum.with_index()
  |> Enum.map(fn {line, index} ->
      Regex.scan(~r/[*]/, line, return: :index)
      |> List.flatten()
      |> Enum.map(fn {start, _} -> {index, start} end)
    end)
  |> Enum.reject(fn l -> length(l) < 1 end)
  |> List.flatten()
  |> IO.inspect()
  gears
  |> Enum.reduce(%{}, fn {y, x}, acc ->
    IO.puts("Finding intersecting locations for #{y}, #{x}")
    Map.put(acc, {y, x}, find_intersecting_locations(y, x, nums))
    end)
  |> Map.values()
  |> IO.inspect()
  |> Enum.filter(fn l -> length(l) > 1 end)
  |> Enum.map(&List.to_tuple/1)
  |> Enum.map(fn {x, y} -> x * y end)
  |> Enum.sum()
  |> IO.inspect()

  end

defp find_intersecting_locations(gear_y, gear_x, number_locations) do
   [number_locations[{gear_y + 1, gear_x}],
    number_locations[{gear_y - 1, gear_x}],
    number_locations[{gear_y, gear_x + 1}],
    number_locations[{gear_y, gear_x - 1}],
    number_locations[{gear_y + 1, gear_x + 1}],
    number_locations[{gear_y - 1, gear_x - 1}],
    number_locations[{gear_y + 1, gear_x - 1}],
    number_locations[{gear_y - 1, gear_x + 1}]
  ]
  |> Enum.filter(fn x -> x != nil end)
  |> Enum.uniq()
end

end

res = Day3Pt22.process_file("day3Realz.txt")

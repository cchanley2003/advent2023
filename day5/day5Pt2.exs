defmodule Day5Pt2 do
  def process_file(file_path) do
    content = File.read!(file_path)
    seeds = get_seeds(content)

    seed_soil_map = map_generator(content, "seed-to-soil map:")
    soil_to_fertilizer_map = map_generator(content, "soil-to-fertilizer map:")
    fertilizer_to_water_map = map_generator(content, "fertilizer-to-water map:")
    water_to_light_map = map_generator(content, "water-to-light map:")
    light_to_temperature_map = map_generator(content, "light-to-temperature map:")
    temperature_to_humidity_map = map_generator(content, "temperature-to-humidity map:")
    humidity_to_location_map = map_generator(content, "humidity-to-location map:")

    seeds
    |> Enum.map(&apply_mapping(&1, seed_soil_map))
    |> List.flatten()
    |> dbg()
    |> Enum.map(&apply_mapping(&1, soil_to_fertilizer_map))
    |> List.flatten()
    |> dbg()
    |> IO.inspect(charlists: :as_lists)
    |> Enum.map(&apply_mapping(&1, fertilizer_to_water_map))
    |> List.flatten()
    |> IO.inspect(charlists: :as_lists)
    |> Enum.map(&apply_mapping(&1, water_to_light_map))
    |> List.flatten()
    |> IO.inspect(charlists: :as_lists)
    |> Enum.map(&apply_mapping(&1, light_to_temperature_map))
    |> List.flatten()
    |> IO.inspect(charlists: :as_lists)
    |> Enum.map(&apply_mapping(&1, temperature_to_humidity_map))
    |> List.flatten()
    |> IO.inspect(charlists: :as_lists)
    |> Enum.map(&apply_mapping(&1, humidity_to_location_map))
    |> List.flatten()
    |> IO.inspect(charlists: :as_lists)
    |> Enum.map(fn {start, stop} -> start end)
    |> Enum.min()
    |> IO.inspect()

  end

  def apply_mapping(range, mapping) do
    splits = Enum.map(mapping, fn {s, e, _} ->
      split_interval(range, {s, e})
    end)
    |> List.flatten()
    |> Enum.reject(&(&1 == nil))
    |> Enum.sort()
    |> IO.inspect(charlists: :as_lists)

    splits = if splits == [], do: [range], else: splits

    applied = merge_list(splits)
    |> Enum.map(fn r ->
      mapping
      |> Enum.map(&adjust_interval(r, &1))
      |> find_first_adjustment()
    end)
    |> Enum.map(fn {start, stop, _} -> {start, stop} end)
    |> Enum.sort()

    if applied == [], do: [range], else: merge_list(applied)
  end

  defp find_first_adjustment(list) do
    Enum.find(list, List.first(list), fn {_, _, adjustment} -> adjustment end)
  end


  def merge_list([]), do: []
  def merge_list(list) do
    merge(hd(list), tl(list))
  end

  def merge({start, stop}, [{prev_start, prev_stop} | tail] = remainder) do
    cond do
      prev_start <= stop ->  merge({start, prev_stop}, tail)
      true -> [{start, stop}] ++ merge_list(remainder)
    end
  end

  def merge({start, stop}, []), do: [{start, stop}]

  def adjust_interval({start, stop}, {s, e, delta}) do
    if s <= start and e >= stop do
      {start + delta, stop + delta, true}
    else
      {start, stop, false}
    end
  end

  def split_interval({start, stop}, {s, e}) do
    # IO.puts("Splitting #{start}, #{stop} from #{s}, #{e}")
    cond do
      start >= s and stop <= e ->
        # IO.inspect("Range Contains")
        [{start, stop}]
      start < s and stop > e ->
        # IO.inspect("Range is contained")
        [{start, s-1}, {s , e}, {e + 1, stop}]
      s >= start and s <= stop ->
        # IO.inspect("Range ends in")
        [{start, s-1}, {s , stop }]
      start > s and start <= e and stop > e ->
        # IO.inspect("Range stars in")
        [{start, e}, {e + 1, stop}]
      true ->
        # IO.inspect("Range is disjoint")
        nil
    end
  end


  def get_seeds(content) do
    seeds_str = String.split(content, "\n")
    |> hd()
    seeds = Regex.scan(~r/(\d+)/, seeds_str)
    |> Enum.map(&tl/1)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
    |> Enum.map(fn {x, y} -> {x, x + y} end)
    |> IO.inspect(charlists: :as_lists)
  end

  def map_generator(content, map_type) do
    seed_soil_map = Regex.run(~r/#{map_type}([\s\S]*?)\n\s*\n/, content)
    |> List.last()
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      capture = Regex.scan(~r/(\d+)/, line)
      |> Enum.map(&tl/1)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)
      end)
      |> Enum.map(&List.to_tuple/1)
      |> Enum.map(fn {destination_start, source_start, range} ->
        {source_start, source_start + range - 1, destination_start - source_start}
      end)
  end
end

Day5Pt2.process_file("day5Realz.txt")

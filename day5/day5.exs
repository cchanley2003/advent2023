defmodule Day5 do
  def process_file(file_path) do
    content = File.read!(file_path)
    seeds = get_seeds(content)

    seed_soil_map = map_generator(content, "seed-to-soil map:")
    |> IO.inspect()
    soil_to_fertilizer_map = map_generator(content, "soil-to-fertilizer map:")
    |> IO.inspect()
    fertilizer_to_water_map = map_generator(content, "fertilizer-to-water map:")
    |> IO.inspect()
    water_to_light_map = map_generator(content, "water-to-light map:")
    |> IO.inspect()
    light_to_temperature_map = map_generator(content, "light-to-temperature map:")
    |> IO.inspect()
    temperature_to_humidity_map = map_generator(content, "temperature-to-humidity map:")
    |> IO.inspect()
    humidity_to_location_map = map_generator(content, "humidity-to-location map:")
    |> IO.inspect()

    seeds
    |> Enum.map(&apply_mapping(&1, seed_soil_map))
    |> IO.inspect(charlists: :as_lists)
    |> Enum.map(&apply_mapping(&1, soil_to_fertilizer_map))
    |> IO.inspect(charlists: :as_lists)
    |> Enum.map(&apply_mapping(&1, fertilizer_to_water_map))
    |> IO.inspect(charlists: :as_lists)
    |> Enum.map(&apply_mapping(&1, water_to_light_map))
    |> IO.inspect(charlists: :as_lists)
    |> Enum.map(&apply_mapping(&1, light_to_temperature_map))
    |> IO.inspect(charlists: :as_lists)
    |> Enum.map(&apply_mapping(&1, temperature_to_humidity_map))
    |> IO.inspect(charlists: :as_lists)
    |> Enum.map(&apply_mapping(&1, humidity_to_location_map))
    |> IO.inspect(charlists: :as_lists)
    |> Enum.min()
    |> IO.inspect()

  end

  defp apply_mapping(number, [{s, e, delta} | tail]) do
    if number >= s and number <= e do
      number + delta
    else
      apply_mapping(number, tail)
    end
  end


  defp apply_mapping(number, []),  do: number

  def get_seeds(content) do
    seeds_str = String.split(content, "\n")
    |> hd()
    seeds = Regex.scan(~r/(\d+)/, seeds_str)
    |> Enum.map(&tl/1)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
    |> IO.inspect()
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

Day5.process_file("day5Realz.txt")

defmodule Day4Pt1 do

  def process_file(path) do
    File.stream!(path)
    |> Enum.map(fn line ->
        line
        |> String.split(":")
        |> List.last()
        |> String.trim()
        |> String.split("|")
        |> Enum.map(fn x -> String.trim(x) end)
        |> Enum.map(fn part ->
          Regex.scan(~r/\d+/, part)
          |> List.flatten()
          |> Enum.map(fn x ->
            String.to_integer(x)
           end)
          |> MapSet.new()
        end)
      end)
    |> Enum.map(&List.to_tuple/1)
    |> Enum.map(fn {x, y} -> MapSet.intersection(x, y) end)
    |> Enum.map(fn x -> length(MapSet.to_list(x))  end)
    |> Enum.filter(fn x -> x > 0 end)
    |> Enum.map(fn x -> :math.pow(2, x - 1 ) end)
    |> Enum.sum()
    |> IO.inspect()
  end
end

Day4Pt1.process_file("day4Realz.txt")

defmodule Day2 do
  def process_file(file_path) do
    File.stream!(file_path)
    |> Enum.map(&process_line/1)
    |> Enum.filter(fn {_, map} ->
        cond do
          map["blue"] != nil and map["blue"] > 14 -> false
          map["green"] != nil and map["green"] > 13 -> false
          map["red"] != nil and map["red"] > 12 -> false
          true -> true
        end
      end)
    |> IO.inspect()
    |> Enum.reduce(0, fn {game, _}, acc ->
        acc + game
      end)
    end

    def process_file_2(file_path) do
      File.stream!(file_path)
      |> Enum.map(&process_line/1)
      |> Enum.map(fn {_, map} ->
        Map.values(map)
        |> Enum.reduce(1, fn value, acc ->
            acc * value
          end)
        end)
      |> Enum.sum()
    end

  defp process_line(line) do
    split = line
        |> String.split(": ")

    [ game | rem ] = split

    matches = Regex.scan(~r/(\d+)\s+(blue|green|red)/, hd(rem) )
    game_match = hd(Regex.run(~r/(\d+)/, game))
    res = Enum.map(matches, fn [ _ | t] ->
      [String.to_integer(hd(t)) | tl(t)]
      |> List.to_tuple()
    end)
    |> Enum.reduce(%{}, fn {number, color}, map ->
        Map.update(map, color, number, fn value -> if number > value, do: number, else: value end)
      end)
      {String.to_integer(game_match), res}
  end
end

res = Day2.process_file_2("day2Realz.txt")
IO.puts(res)

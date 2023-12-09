defmodule Day4Pt1 do

  def process_file(path) do
    wins_and_cards = File.stream!(path)
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
    |> Enum.map(fn x -> {x, 1} end)
    |> ListModifier.modify_list()
    |> Enum.reduce(0, fn {_, cards}, acc -> acc + cards end)
    |> IO.inspect()

  end

end
defmodule ListModifier do
  def modify_list(list), do: do_modify(list, [])

  defp do_modify([], acc), do: Enum.reverse(acc)
  defp do_modify([head | tail], acc) do
    # Modify the tail based on the head value, then continue modifying the rest of the list
    {modified_tail, remaining_tail} = do_modify_tail(tail, head)
    do_modify(remaining_tail, [head | acc] ++ modified_tail)
  end

  defp do_modify_tail(tail, 0), do: {[], tail}
  defp do_modify_tail([], _), do: {[], []}
  defp do_modify_tail([head | tail], count) when count > 0 do
    {modified_tail, remaining_tail} = do_modify_tail(tail, count - 1)
    {[head + 1 | modified_tail], remaining_tail}
  end
end
defmodule ListModifier do
  def modify_list(list) do
    increment_all_helper(list, [])
  end

  defp increment_all_helper([], acc), do: acc

  defp increment_all_helper([{wins, cards} | tail], acc) do
    tail = modify_tail(tail, cards, wins)
    increment_all_helper(tail, acc ++ [{wins, cards}])
  end

  defp modify_tail(list, _, 0) do
    list
  end

  defp modify_tail([], _, _), do: []

  defp modify_tail([{wins, cards} | tail], up, count) do
    [{wins, cards + up} | modify_tail(tail,up, count - 1)]
  end
end


Day4Pt1.process_file("day4Realz.txt")

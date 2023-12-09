defmodule Day7 do
  @card_ranks  %{
    "A" => 14,
    "K" => 13,
    "Q" => 12,
    "J" => 11,
    "T" => 10,
    "9" => 9,
    "8" => 8,
    "7" => 7,
    "6" => 6,
    "5" => 5,
    "4" => 4,
    "3" => 3,
    "2" => 2
  }

  def process_file(file_path) do
    File.stream!(file_path)
    |> Enum.map(fn line ->
        line
        |> String.trim()
        |> String.split(" ")
      end)
      |> Enum.map(&List.to_tuple/1)
      |> Enum.map(fn {x, y} -> {x, String.to_integer(y)} end)
      |> Enum.map(fn {x, y} -> {generate_strength(x), x, y} end)
      |> Enum.sort(fn {x, hand1, _}, {y, hand2, _} ->
        if x == y do
          compare_hands(hand1, hand2)
        else
          x > y
        end
      end)
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.map(fn {{_, _, bid}, index} -> bid * (index + 1)  end)
      |> Enum.sum()
      |> IO.inspect()
  end

  def compare_hands(hand1, hand2), do: do_compare(String.graphemes(hand1), String.graphemes(hand2))

  defp do_compare([], []), do: true
  defp do_compare([], _), do: :second_higher
  defp do_compare(_, []), do: :first_higher

  defp do_compare([c1 | rest1], [c2 | rest2]) do
    cond do
      @card_ranks[c1] == @card_ranks[c2] -> do_compare(rest1, rest2)
      @card_ranks[c1] > @card_ranks[c2] -> true
      true -> false
    end
  end


  def generate_strength(hand) do
    values = hand
    |> String.graphemes()
    |> Enum.reduce(%{}, fn char, map ->
      Map.update(map, char, 1, &(&1 + 1))
    end)
    |> Map.values()
    |> Enum.sort()
    |> Enum.reverse()

    cond do
      hd(values) >= 4 -> hd(values) + 2
      hd(values) == 3 and (hd(tl(values))) >= 2 -> hd(values) + 2
      hd(values) == 3 -> hd(values) + 1
      hd(values) == 2 and (hd(tl(values))) == 2 -> hd(values) + 1
      true -> hd(values)
    end
  end
end



# Day7.generate_strength("T55J5") |> IO.inspect()
Day7.process_file("day7Realz.txt")

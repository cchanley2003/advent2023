defmodule Day7 do
  @card_ranks  %{
    "A" => 14,
    "K" => 13,
    "Q" => 12,
    "T" => 10,
    "9" => 9,
    "8" => 8,
    "7" => 7,
    "6" => 6,
    "5" => 5,
    "4" => 4,
    "3" => 3,
    "2" => 2,
    "J" => 1,

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
      |> IO.inspect()
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
    map_of_cards = hand
    |> String.graphemes()
    |> Enum.reduce(%{}, fn char, map ->
      Map.update(map, char, 1, &(&1 + 1))
    end)

    jokers = map_of_cards["J"] || 0
    dbg(jokers)
    values =
    map_of_cards
    |> Map.delete("J")
    |> IO.inspect()
    |> Map.values()
    |> Enum.sort()
    |> Enum.reverse()

    top =
      if jokers == 5 do
        5
      else
        head(values) + jokers
      end
    next = if top < 4 do
      head(tl(values))
    else
      0
    end

    cond do
      top == 5 -> 7
      top == 4 -> 6
      top == 3 and next == 2 -> 5
      top == 3 -> 4
      top == 2 and next == 2 -> 3
      top == 2 -> 2
      true -> 1
    end
    |> IO.inspect()
  end

  def head([]), do: 0

  def head([h | _]), do: h
end



Day7.generate_strength("T55J5") |> IO.inspect()
Day7.generate_strength("QQQJA") |> IO.inspect()
Day7.generate_strength("QQAJA") |> IO.inspect()

Day7.process_file("day7Realz.txt")

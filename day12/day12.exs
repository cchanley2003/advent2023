defmodule Day12 do
  def run(path) do
    l = File.stream!(path)
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn line ->
      regex_question = ~r/(\?)/
      question_locs = Regex.scan(regex_question, line,  return: :index)
      |> Enum.map(fn l -> hd(l) end)
      |> Enum.map(fn {loc, _} -> loc end)
      regex_pound = ~r/(#+)/
      pound_locs = Regex.scan(regex_pound, line,  return: :index)
      |> Enum.map(fn l -> hd(l) end)
      |> Enum.map(fn {loc, delta} -> {loc, loc + (delta - 1)} end)

      regex_goal = ~r/(\d+)/
      goal = Regex.scan(regex_goal, line)
      |> Enum.map(fn l -> String.to_integer(hd(l)) end)
      {question_locs, pound_locs, String.length(line), goal}
    end)
    |> Enum.map(fn {question_locs, pound_locs, length, goal} ->
      sum_options(question_locs, pound_locs, length, goal)
      |> IO.inspect()
    end)
    |> dbg()
    |> Enum.sum()
    |> IO.inspect()
    # {question_locs, pound_locs, length, goal} = hd(l)
    # sum_options(question_locs, pound_locs, length, goal)
    # |> dbg()

  end

  def sum_options(question_locs, ranges, length, goal), do: sum_options(question_locs, ranges, length, goal, 0)
  def sum_options([], ranges, _, goal, acc) do
    cond do
      target_met(ranges, goal) -> acc + 1
      true -> acc
    end
  end

  def sum_options([loc | tail], ranges, length, goal, acc) do
    cond do
      target_met(ranges, goal) -> acc + 1
      can_achieve(loc, length, ranges, goal) == false -> acc
      check_ranges(ranges, goal) == false -> acc
      true ->
        merged_ranges = merge_ranges([{loc, loc} | ranges])
        sum_options(tail, merged_ranges, length, goal, acc) + sum_options(tail, ranges, length, goal, acc)
    end
  end

  def target_met(ranges, goal) do
    cond do
      length(goal) != length(ranges) ->
        false
      true ->
        Enum.sort(ranges)
        |> Enum.zip(goal)
        |> Enum.all?(fn {{start, stop}, g} -> g == (stop - start + 1) end)
    end
  end

  def can_achieve(loc, length, ranges, goal) do
    remain = length - (loc  + 1)
    goal_length = Enum.sum(goal)
    so_far = Enum.map(ranges, fn {start, stop} -> stop - start + 1 end) |> Enum.sum()
    cond do
      goal_length - so_far > remain ->
        false
      true ->
        true
    end
  end

  def check_ranges([], goal), do: true
  def check_ranges(ranges, goal) do
    sum = Enum.sum(goal)
    range_deltas = ranges
    |> Enum.map(fn {start, stop} -> stop - start + 1 end)

    range_sum = Enum.sum(range_deltas)
    cond do
      range_sum > sum ->
        false
      Enum.max(range_deltas) > Enum.max(goal) ->
        false
      true ->
        true
    end
  end

  def merge_ranges(ranges) do
    ranges
    |> Enum.sort()
    |> Enum.reduce([], fn {start, stop}, acc ->
        if length(acc) == 0 do
          [{start, stop}]
        else
          {next_start, next_stop} = hd(acc)
          if next_stop + 1 == start do
            [{next_start, stop} | tl(acc)]
          else
            [{start, stop} | acc]
          end
        end
      end)
  end
end

# line = "?###???????? 4,1,11"

# Day12.merge_ranges([{0, 0}, {2, 2}, {4, 6}])
# |> dbg()
# regex_question = ~r/(\d+)/
Day12.run("real.txt")
# Regex.scan(regex_question, line)
# |> dbg()

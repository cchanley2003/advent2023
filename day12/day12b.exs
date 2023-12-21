Mix.install([:memoize])

defmodule Day12Final do

  use Memoize
  def run(path) do
    l = File.stream!(path)
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn line ->
      line_split = String.split(line, " ")
      g = Enum.at(line_split, 1)
      pattern = String.duplicate(hd(line_split) <> "?", 5)
      new_pattern = String.slice(pattern, 0, String.length(pattern) - 1)
      # dbg(pattern)

      regex_goal = ~r/(\d+)/
      goal = Regex.scan(regex_goal, String.duplicate(g <> ",", 5))
      |> Enum.map(fn l -> String.to_integer(hd(l)) end)
      # dbg(goal)
      {new_pattern, goal}
    end)
    |> Enum.map(fn {pattern, goal} ->
      count_options(String.graphemes(pattern), goal, 0)
    end)
    |> IO.inspect()
    |> Enum.sum()
    |> IO.inspect()
  end

  # No streak and nothing left to look for
  defmemo count_options(rem, [], 0) do
    # If we still have a spring, we can't have a match
    if Enum.any?(rem, fn x -> x == "#" end) do
      0
    else
      1
    end
  end

  # We ran out of characters but have a streak going
  defmemo count_options([], [goal | rem], streak) do
    # The final character ends the streak and handles the last goal
    if streak == goal and rem == [] do
      # IO.puts("We have a match")
      1
    else
      # IO.puts("We have a mismatch")
      0
    end
  end

  # We have a spring up the streak
  defmemo count_options(["#" | tail], goal, streak) do
    count_options(tail, goal, streak + 1)
  end

  # We have a dot. We need to end the streak and check for violations
  defmemo count_options(["." | tail], [goal | rem] = ag, streak) do
    cond do
      streak == 0 ->
        # Just another dot, continue on
        count_options(tail, ag, 0)
      streak > 0 and streak == goal ->
        # End the streak and shrink the goal list
        count_options(tail, rem, 0)
      true ->
        # IO.puts("We ended a streak without matching the goal")
        0
    end
  end

  # Let us do both options
  defmemo count_options(["?" | rest], goal, streak) do
    # Replace the head of the stream with both options
    count_options(["#" | rest], goal, streak) + count_options(["." | rest], goal, streak)
  end
end

# line = ".#.?.??..?#"
# Day12Final.count_options(String.graphemes(line), [1, 1, 2], 0, [])
# |> dbg()

Day12Final.run("real.txt")

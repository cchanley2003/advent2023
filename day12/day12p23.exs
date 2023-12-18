
defmodule Day12Final do

  def run(path) do
    l = File.stream!(path)
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn line ->
      line_split = String.split(line, " ")
      g = Enum.at(line_split, 1)
      pattern = hd(line_split)

      regex_goal = ~r/(\d+)/
      goal = Regex.scan(regex_goal, g)
      |> Enum.map(fn l -> String.to_integer(hd(l)) end)
      {pattern, goal}
    end)
    |> Enum.map(fn {pattern, goal} ->
      count_options(String.graphemes(pattern), goal, 0)
    end)
    # |> IO.inspect()
    |> Enum.sum()
    |> IO.inspect()
  end
  def count_options(rem, [], 0) do
    if Enum.any?(rem, fn x -> x == "#" end) do
      0
    else
      1
    end
  end

  def count_options(_, [], _) do
    0
  end

  def count_options([], [goal | rem], streak) do
    if streak == goal and rem == [] do
      # IO.puts("We have a match")
      1
    else
      # IO.puts("We have a mismatch")
      0
    end
  end

  def count_options(["#" | tail], goal, streak) do
    count_options(tail, goal, streak + 1)
  end

  def count_options(["." | tail], [goal | rem] = ag, streak) do
    # IO.puts("We have a dot")
    # dbg(state)
    # dbg(ag)
    # dbg(streak)
    cond do
      streak == 0 ->
        count_options(tail, ag, 0)
      streak > 0 and streak == goal ->
        count_options(tail, rem, 0)
      true ->
        # IO.puts("We ended a streak without matching the goal")
        0
    end
  end

  def count_options(["?" | rest], goal, streak) do
    # IO.puts("We have a question mark")
    # dbg(state)
    # dbg(goal)
    # dbg(streak)
    count_options(["#" | rest], goal, streak) + count_options(["." | rest], goal, streak)
  end
end

# line = ".#.?.??..?#"
# Day12Final.count_options(String.graphemes(line), [1, 1, 2], 0, [])
# |> dbg()

Day12Final.run("real.txt")

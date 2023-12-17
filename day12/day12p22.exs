Mix.install([:memoize])

defmodule Day12 do
  use Memoize

  def process_file(path) do
    File.stream!(path)
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
      search(String.graphemes(pattern), goal)
    end)
    |> Enum.sum()
    |> IO.inspect()
  end

  defmemo search(list, [g | rest] = goals)  do
    dbg(list)
    dbg(g)
    adjust_list = Enum.drop_while(list, fn x -> x == "." end)
    downstream  = search_current(adjust_list, g, false)
    |> Enum.filter(fn {_, x} -> x end)
    |> Enum.map(fn {x, _} -> x end)
    |> Enum.uniq()
    |> IO.inspect()

    if rest == [] do
      downstream
      |> dbg()
      |> Enum.filter( fn l -> not(Enum.any?(l, fn x -> x == "#" end)) end)
      |> dbg()
      |> length()
    else
      Enum.reduce(downstream, 0, fn l, acc -> acc +
      search(Enum.drop(l, 1), rest) end)
    end
  end


  defmemo search_current(list, goal, changed), do: search_current(list, goal, [], changed)
  defmemo search_current([el | _], 0, _,  _) when el == "#", do: [{[], false}]
  defmemo search_current(rest, 0, acc, _), do: [ {rest, true} | acc ]
  defmemo search_current([], _, _, _), do: [{[], false}]

  defmemo search_current([el | rest], goal, acc, changed) do
    cond do
      el == "#" ->
        search_current(rest, goal - 1, true) ++ acc
      el == "?" ->
        search_current(rest, goal - 1, true) ++ search_current(rest, goal, changed) ++ acc
      el == "." and not(changed) ->
        search_current(rest, goal, changed) ++ acc
      true ->
        [{[], false}]
    end
  end
end

# Day12.process_file("real.txt")

line = ".???#????#?????#?#?"
Day12.search(String.graphemes(line), [1, 9, 4])
|> dbg()


# line = String.graphemes(".??..??...?##.")
# line
# |> Enum.drop_while(fn x -> x == "." end)
# |> Day12.search_current(1)
# |> dbg()
# |> Enum.filter(fn x -> x != false end)
# |> dbg()
# |> Enum.map(fn x -> Day12.search_current(Enum.drop(x, 1), 1) end)
# |> dbg()

# Day12.search_current(String.graphemes("#"), 1)
# |> dbg()

# Day12.merge_ranges([{0, 0}, {2, 2}, {4, 6}])
# |> dbg()
# regex_question = ~r/(\d+)/
# Day12.run("sample.txt")
# Regex.scan(regex_question, line)
# |> dbg()

# candidate is number
# walk forward in list till pound is hit or ? (drop while?)
# once on a ? or # try to satisfy the number
# if it is a pound I have to take it, if I take it it and the number is equal peak isolate it
# if it is a pound and the number is greater then goal return 0
# if it is a question mark turn it on and see if I am at goal, if so isolate it and return 1, plus the rest of the list
# Turn off the question mark and keep looking

# line = ".???"
# Day12.search(String.graphemes(line), [1, 1])
# |> dbg()

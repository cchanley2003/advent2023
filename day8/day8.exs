
defmodule Day8 do
  def process_file(path) do
    stream = File.stream!(path)
    [first | _ ] = Enum.take(stream, 1)

    cmds = first
    |> String.trim()
    |> String.graphemes()

    tree_tuples = stream
    |> Stream.drop(2)
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn line ->
         String.split(line, " = ")
       end)
    |> Enum.map(&List.to_tuple/1)
    |> Enum.map(fn {root, leaf} ->
         regex = ~r/\(([^,]+),\s*([^)]+)\)/
         parsed = Regex.run(regex, leaf)
         |> tl()
         |> List.to_tuple()
        {root, parsed}
        end)
    # |> IO.inspect()

    tree_map = tree_tuples
    |> Enum.reduce(%{},
      fn {root, leafs}, acc ->
        Map.put(acc, root, leafs)
    end)
    # |> IO.inspect()

    segments = tree_map
    |> Map.keys()
    |> Enum.reduce(%{}, fn el, acc ->
      Map.put(acc, el, walk(el, cmds, tree_map))
    end)
    # |> IO.inspect()

    sum("AAA", segments)
    |> IO.inspect()
  end

  def sum(el, segs), do: sum(el, segs, 0)

  def sum("ZZZ", _, sum), do: sum

  def sum(el, segs, sum) do
    {n, steps} = segs[el]
    sum(n, segs, sum + steps)
  end

  def walk(el, cmds, tree), do: walk(el, cmds, tree, 0)

  def walk("ZZZ", _, _, count), do: {"ZZZ", count}

  def walk(el, [], _, count), do: {el, count}

  def walk(el, [cmd | cmds], tree, count) do
    t = tree[el]
    n = if cmd == "L" do
      elem(t, 0)
    else
      elem(t, 1)
    end
    walk(n, cmds, tree, count + 1)
  end
end

Day8.process_file("real.txt")

defmodule Day8p2 do
  def process_file(path) do
    stream = File.stream!(path)
    [first | _] = Enum.take(stream, 1)

    cmds =
      first
      |> String.trim()
      |> String.graphemes()

    tree_map =
      stream
      |> Stream.drop(2)
      |> Enum.map(&String.trim/1)
      |> Enum.map(fn line ->
        String.split(line, " = ")
      end)
      |> Enum.map(&List.to_tuple/1)
      |> Enum.map(fn {root, leaf} ->
        regex = ~r/\(([^,]+),\s*([^)]+)\)/

        parsed =
          Regex.run(regex, leaf)
          |> tl()
          |> List.to_tuple()

        {root, parsed}
      end)
      |> IO.inspect()
      |> Enum.reduce(
        %{},
        fn {root, leafs}, acc ->
          Map.put(acc, root, leafs)
        end
      )
      |> IO.inspect()

    zels =
      tree_map
      |> Map.keys()
      |> Enum.filter(fn el ->
        String.ends_with?(el, "Z")
      end)
      |> IO.inspect()

    aels =
      tree_map
      |> Map.keys()
      |> Enum.filter(fn el ->
        String.ends_with?(el, "A")
      end)
      |> IO.inspect()

    segs =
      tree_map
      |> Map.keys()
      |> Enum.map(fn el ->
        {el, walk(el, zels, cmds, tree_map)}
      end)
      |> Enum.reduce(%{}, fn {el, l}, acc ->
        Map.put(acc, el, l)
      end)
      |> IO.inspect()

    aels
    |> Enum.map(fn el ->
      {el, distance_to_first_z(el, segs)}
    end)
    |> IO.inspect()
    |> Enum.map(fn {_, dist} ->
      dist
    end)
    |> Enum.reduce(1, fn el, acc ->
      lcm(trunc(acc), el)
    end)
    |> IO.inspect()

  end

  def lcm(a, b) do
    a * b / Integer.gcd(a, b)
  end
  def distance_to_first_z(el, segs), do: distance_to_first_z(el, segs, 0)

  def distance_to_first_z(el, segs, sum) do
    if String.ends_with?(el, "Z") do
      sum
    else
      {n, steps} = segs[el]
      |> Enum.reverse()
      |> hd()
      distance_to_first_z(n, segs, sum + steps)
    end
  end

  def walk(el, zs, cmds, tree), do: walk(el, zs, cmds, tree, 0, [])

  def walk(el, zs, [], _, count, acc), do: [{el, count} | acc]

  def walk(el, zs, [cmd | cmds], tree, count, acc) do
    with_z =
      if(String.ends_with?(el, "Z") and count != 0) do
        [{el, count} | acc]
      else
        acc
      end

    t = tree[el]

    n =
      if cmd == "L" do
        elem(t, 0)
      else
        elem(t, 1)
      end

    walk(n, zs, cmds, tree, count + 1, with_z)
  end
end

Day8p2.process_file("real.txt")

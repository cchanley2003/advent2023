Mix.install([:heap])
defmodule Day23 do

  @options %{"." => [{0, 1}, {1, 0}, {0, -1}, {-1, 0}],
               ">" => [{1, 0}], "<" => [{-1, 0}], "^" => [{0, -1}], "v" => [{0, 1}]}
  def process(path) do
    grid = File.stream!(path)
    |> Enum.map(&String.trim/1)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, grid ->
      String.graphemes(line)
      |> Enum.with_index()
      |> Enum.reduce(grid, fn {char, x}, grid ->
        Map.put(grid, {x, y}, char)
      end)
    end)

    no_forests = grid
    |> Enum.filter(fn {_, c} -> c != "#" end)
    |> Map.new()

    graph = no_forests
    |> Enum.map(fn {loc, _} = place -> {loc, get_leafs(no_forests, place)} end)
    |> Map.new()

    dbg(graph)
    dbg(Map.get(graph, {16, 7}))
    dbg(Map.get(graph, {17, 9}))

    start = {1, 0}

    finish = {max_x, max_y}  = Map.keys(no_forests)
    |> Enum.reduce({0, 0}, fn {x, y}, {mx, my} -> {max(mx, x), max(my, y)} end)    # dfs(graph, start, finish, %{}, 0)
    # compact_graph(graph)
    # |> IO.inspect()
    # |> dfs(start, finish, %{}, 0)

    # weighted_graph = graph
    # |> Enum.map(fn {k, v} -> {k, Enum.map(v, fn x -> {x, 1} end)} end) |> Map.new()
    # |> dfs(start, finish, %{}, 0)
    compact_graph(graph)
    |> IO.inspect()
    |> dfs(start, finish, %{}, 0)

  end




  def compact_graph(graph) do
    twos = graph
    |> Enum.filter(fn {_, v} -> length(v) == 2 end)
    |> Enum.map(fn {k, _} -> k end)

    weighted_graph = graph
    |> Enum.map(fn {k, v} -> {k, Enum.map(v, fn x -> {x, 1} end)} end) |> Map.new()
    bridge_twos(weighted_graph, twos)
  end

  def bridge_twos(wg, []), do: wg
  def bridge_twos(wg, [two | rest]) do
    [a, b] = Map.get(wg, two)
    wg = bridge(wg, a, two, b)
    bridge_twos(wg, rest)
  end

  def bridge(wg, {a, ac}, bridge, {b, bc}) do
    wg = Map.delete(wg, bridge)

    # dbg(bridge)
    # dbg(a)
    # dbg(b)
    # dbg(Map.get(wg, a))
    # dbg(Map.get(wg, b))
    a_to_bridge = Map.get(wg, a) |> Map.new() |> Map.get(bridge)
    b_to_bridge = Map.get(wg, b) |> Map.new() |> Map.get(bridge)

    a_edges = Map.get(wg, a)
    |> Enum.filter(fn {x, _} -> x != bridge end)
    |> List.insert_at(0, {b, a_to_bridge + bc})

    b_edges = Map.get(wg, b)
    |> Enum.filter(fn {x, _} -> x != bridge end)
    |> List.insert_at(0, {a, ac+ b_to_bridge})

    # dbg(a_edges)
    # dbg(b_edges)

    Map.put(wg, a, a_edges)
    |> Map.put(b, b_edges)
  end

  # def bridge(wg, {a, _}, bridge, {b, _}) do
  #   dbg(a)
  #   wg = Map.delete(wg, bridge)
  #   a_edges = Map.get(wg, a)
  #   |> IO.inspect()
  #   |> Enum.filter(fn {x, _} -> x != bridge end)
  #   dbg(a_edges)

  #   dbg(bridge)
  #   dbg(b)
  #   b_edges = Map.get(wg, b)
  #   |> IO.inspect()
  #   |> Enum.filter(fn {x, _} -> x != bridge end)

  #   dbg(b_edges)

  #   a_plus = Enum.map(a_edges, fn {x, w} -> {x, w + 1} end) |> Map.new()
  #   b_plus = Enum.map(b_edges, fn {x, w} -> {x, w + 1} end) |> Map.new()

  #   dbg(a_plus)
  #   dbg(b_plus)

  #   wg = Map.put(wg, a, Map.merge(Map.new(a_edges), b_plus, fn _, a, b -> max(a, b) end) |> Map.to_list())
  #   wg = Map.put(wg, b, Map.merge(Map.new(b_edges), a_plus, fn _, a, b -> max(a, b) end) |> Map.to_list())
  #   dbg(Map.get(wg, a))
  #   dbg(Map.get(wg, b))
  #   wg

  # end
  def dfs(_, loc, finish, _, count) when loc == finish do
    count
  end
  def dfs(graph, loc, finish, seen, count) do
    res = Map.get(graph, loc)
    |> Enum.filter(fn {x, _} -> !Map.get(seen, x, false) end)
    |> Enum.map(fn {x, w} -> dfs(graph, x, finish, Map.put(seen, x, true), count + w) end)

    if res == [] do
      0
    else
      Enum.max(res)
    end
  end


  def get_leafs(grid, {{x, y}, char}) do
    option =[{0, 1}, {1, 0}, {0, -1}, {-1, 0}]
    Enum.reduce(option, [], fn {dx, dy}, acc ->
      nl = {x + dx, y + dy}
      if Map.has_key?(grid, nl) do
        [nl | acc]
      else
        acc
      end
    end)
  end
end

Day23.process("real.txt")
|> IO.inspect()

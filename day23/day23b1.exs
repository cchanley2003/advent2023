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

    start = {1, 0}

    finish = {max_x, max_y}  = Map.keys(no_forests)
    |> Enum.reduce({0, 0}, fn {x, y}, {mx, my} -> {max(mx, x), max(my, y)} end)

    dbg(finish)
    dfs(graph, start, finish, %{start => true}, 0)
  end

  # def find_longest(graph, queue, finish, seen) do
  #   {{neg_steps, top}, rest} = Heap.split(queue)
  #   IO.puts("Steps #{neg_steps}")
  #   dbg(top)
  #   dbg(rest)
  #   dbg(seen)
  #   if finish == top do
  #     neg_steps * -1
  #   else
  #     {queue, seen} = Enum.reduce(Map.get(graph, top), {rest, seen}, fn x, {h, s} ->
  #       distance = Map.get(seen, x, Integer.MAX_VALUE)
  #       new_dist = neg_steps - 1
  #       if new_dist < distance do
  #         {Heap.push(h, {new_dist, x}), Map.put(seen, x, new_dist)}
  #       else
  #         {h, s}
  #       end
  #     end)
  #     find_longest(graph, queue, finish, seen)
  #   end
  # end

  def compact_graph(graph) do
    twos = graph
    |> Enum.filter(fn {_, v} -> length(v) == 2 end)
    |> Enum.map(fn {k, _} -> k end)

    weighted_graph = graph
    |> Enum.map(fn {k, v} -> {k, Enum.map(v, fn x -> {x, 2} end)} end) |> Map.new()
    bridge_twos(weighted_graph, twos)
  end

  def dfs(_, loc, finish, _, count) when loc == finish do
    count
  end

  def dfs(graph, loc, finish, seen, count) do
    res = Map.get(graph, loc)
    |> Enum.filter(fn x -> !Map.get(seen, x, false) end)
    |> Enum.map(fn x -> dfs(graph, x, finish, Map.put(seen, x, true), count + 1) end)

    dbg(seen)
    dbg(res)
    if res == [] do
      count
    else
      Enum.max(res)
    end
  end


  def get_leafs(grid, {{x, y}, char}) do
    option  = Map.get(@options, char)
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

Day23.process("sample.txt")
|> IO.inspect()

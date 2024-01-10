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

    dfs(graph, start, finish, %{}, 0)
  end

  def dfs(_, loc, finish, _, count) when loc == finish do

    count
  end

  def dfs(graph, loc, finish, seen, count) do
    res = Map.get(graph, loc)
    |> Enum.filter(fn x -> !Map.get(seen, x, false) end)
    |> Enum.map(fn x -> dfs(graph, x, finish, Map.put(seen, x, true), count + 1) end)

    if res == [] do
      0
    else
      Enum.max(res)
    end
  end


  def get_leafs(grid, {{x, y}, char}) do
    option = [{0, 1}, {1, 0}, {0, -1}, {-1, 0}]
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

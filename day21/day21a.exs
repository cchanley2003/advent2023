defmodule Day21a do
  @steps [{0, -1}, {1, 0}, {0, 1}, {-1, 0}]
  def process(path) do
    grid =
      File.stream!(path)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {line, y}, grid ->
        String.trim(line)
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(grid, fn {char, x}, grid ->
          Map.put(grid, {x, y}, char)
        end)
      end)
    {start, _} = grid
    |> Enum.filter(fn {_, c} -> c == "S" end)
    |> hd()

    walk(grid, [{start, 0}], 64, 0, [], MapSet.new())
    |> IO.inspect()
    |> Enum.filter(fn {_, s} -> rem(s, 2) == 0 end)
    |> IO.inspect()
    |> length()
  end

  def walk(_, _, goal, step, visited, seen) when goal == step do
    visited
  end

  def walk(grid, locs, goal, step, visited, seen) do
    IO.puts("Looking at step #{step} with #{length(locs)} locations")
    dbg(locs)

    {next, seen} = locs
    |> Enum.reduce({[], seen}, fn {loc, _}, {acc, seen} ->
      next =
        get_next(grid, loc)
        |> Enum.reject(fn x -> MapSet.member?(seen, x) end)
        |> Enum.map(fn l -> {l, step + 1} end)
      {acc ++ next, MapSet.union(seen, next |> Enum.map(fn {loc, _} -> loc end) |> MapSet.new())}
    end)

    # next =
    #   locs
    #   |> Enum.flat_map(fn {loc, _} ->
    #   get_next(grid, loc)
    #   |> Enum.reject(fn x -> MapSet.member?(seen, x) end)
    #   |> Enum.map(fn l -> {l, step + 1} end)
    # end)
    walk(grid, next, goal, step + 1, visited ++ next, seen)
  end

  def get_next(grid, {x, y}) do
    Enum.reduce(@steps, [], fn step, acc ->
      {dx, dy} = step
      nl = {x + dx, y + dy}
      if Map.has_key?(grid, nl) and Map.get(grid, nl) != "#" do
        [{x + dx, y + dy} | acc]
      else
        acc
      end
    end)
  end

end

Day21a.process("real.txt")
|> IO.inspect()

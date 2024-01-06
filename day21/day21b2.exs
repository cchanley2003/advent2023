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

   visited =  walk(grid, [{start, 0}], 0, [], MapSet.new())

   even = visited
    |> Enum.filter(fn {_, s} -> rem(s, 2) == 0 end)
    |> length()

    odd = visited
    |> Enum.filter(fn {_, s} -> rem(s, 2) == 1 end)
    |> length()

    odd_corner = visited
    |> Enum.filter(fn {_, s} -> rem(s, 2) == 1 end)
    |> Enum.filter(fn {_, s} -> s > 65 end)
    |> length()

    even_corner = visited
    |> Enum.filter(fn {_, s} -> rem(s, 2) == 0 end)
    |> Enum.filter(fn {_, s} -> s > 65 end)
    |> length()

    n = 202300
    (n + 1) * (n + 1) * odd + (n * n) * even - (n + 1) * odd_corner + n * even_corner

  end

  def walk(_, [], step, visited, seen) do
    visited
  end

  def walk(grid, locs, step, visited, seen) do
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
    walk(grid, next, step + 1, visited ++ next, seen)
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

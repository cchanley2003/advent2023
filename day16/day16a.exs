defmodule Day16 do
  def process(path) do
    {grid, tiles} = File.stream!(path)
    |> Enum.with_index()
    |> Enum.reduce({%{}, []}, fn {line, y}, gridplus ->
      String.trim(line)
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(gridplus , fn {char, x}, {g, tiles} ->
        if char == "." do
          { Map.put(g, {x, y}, char), tiles}
        else
          { Map.put(g, {x, y}, char), [ {x,y } | tiles] }
        end
      end)
    end)
    |> IO.inspect()

    maxes =
      Map.keys(grid)
      |> Enum.reduce({0, 0}, fn {x, y}, {max_x, max_y} ->
        {max(x, max_x), max(y, max_y)}
      end)
    tile_set = MapSet.new(tiles)

    collect_spaces(grid, tiles, maxes)
    |> Enum.map(fn l -> Enum.sort(l) end)
    |> Enum.uniq()
    |> dbg()
    |> Enum.map(fn [{x, y}, {x1, y1} | _] -> (x1 - x) + (y1 - y) + 1 end)
    |> Enum.sum()
    |> IO.inspect()
  end

  def collect_spaces(grid, tiles, maxes) do
    collect_spaces(grid, tiles, maxes, :east, {0, 0}, [])
  end

  def collect_spaces(grid, tiles, maxes, dir, loc, acc) do
    IO.inspect({dir, loc})
    next = get_next(tiles, {dir, loc})
    dbg(next)
    if next == nil do
      [[loc, get_edge(grid, dir, loc, maxes)] | acc]
    else
     get_directions(next, grid, dir)
     |> Enum.reduce(acc, fn dir, acc ->
       collect_spaces(grid, tiles, maxes, dir, next, [[loc, next] | acc])
       |> dbg()
     end)
    end
  end

  def get_edge(grid, dir, {x, y}, {max_x, max_y}) do
    case dir do
      :east ->
        {x, max_y}
      :west ->
        {x, 0}
      :north ->
        {0, y}
      :south ->
        {max_x, y}
    end
  end

  def get_directions(loc, grid, dir) do
    tile = Map.get(grid, loc)
    cond do
      tile == "-" ->
        case dir do
          :north -> [:east, :west]
          :south -> [:east, :west]
          :east -> [:east]
          :west -> [:west]
        end
      tile == "|" ->
        case dir do
          :north -> [:north]
          :south -> [:south]
          :east -> [:north, :south]
          :west -> [:north, :south]
        end
      tile == "/" ->
        case dir do
          :north -> [:east]
          :south -> [:west]
          :east -> [:north]
          :west -> [:south]
        end
      tile == "\\" ->
        case dir do
          :north -> [:west]
          :south -> [:east]
          :east -> [:south]
          :west -> [:north]
        end
      true ->
        [:error]
    end
  end

  def get_next(tiles, {exit_dir, {loc_x, loc_y}}) do
    case exit_dir do
      :east ->
        tiles
        |> Enum.filter(fn {x, y} -> x == loc_x end)
        |> IO.inspect()
        |> Enum.sort()
        |> Enum.find(fn {x, y} -> y > loc_y end)
      :west ->
        tiles
        |> Enum.filter(fn {x, y} -> x == loc_x end)
        |> Enum.sort()
        |> Enum.reverse()
        |> Enum.find(fn {x, y} -> y < loc_y end)
      :north ->
        tiles
        |> Enum.filter(fn {x, y} -> y == loc_y end)
        |> Enum.sort()
        |> Enum.reverse()
        |> Enum.find(fn {x, y} -> x < loc_x end)
      :south ->
        tiles
        |> Enum.filter(fn {x, y} -> y == loc_y end)
        |> Enum.sort()
        |> Enum.find(fn {x, y} -> x > loc_x end)
    end
  end

end

Day16.process("sample.txt")

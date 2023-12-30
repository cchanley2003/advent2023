defmodule Day16 do

  def convert_to_zero_or_one(x) do
   if x == 0, do: 0, else: 1
  end


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
    # |> IO.inspect()



    {mx, my} = maxes =
      Map.keys(grid)
      |> Enum.reduce({0, 0}, fn {x, y}, {max_x, max_y} ->
        {max(x, max_x), max(y, max_y)}
      end)

    h_edges = 0..mx
    |> Enum.flat_map(fn x -> [{:south, {x, 0}}, {:north, {x, my}}] end)

    v_edges = 0..my
    |> Enum.flat_map(fn y -> [{:east, {0, y}}, {:west, {mx, y}}] end)

    edges = h_edges ++ v_edges
    |> Enum.map(fn {d, l} = start ->
      if grid[l] == "." do
        start
      else
        get_directions(l, grid, d)
        |> Enum.map(fn d -> {d, l} end)
      end
    end)
    |> List.flatten()

    Enum.map(edges, fn start ->
      collect_spaces(grid, tiles, maxes, start)
      # |> IO.inspect()
      |> Enum.map(fn l -> Enum.sort(l) end)
      |> Enum.uniq()
      |> Enum.flat_map(fn [{x_start, y_start}, {x_end, y_end}]  ->
        fill_until({x_start, y_start}, {x_end, y_end},
        {convert_to_zero_or_one(x_end- x_start), convert_to_zero_or_one(y_end - y_start)})
       end)
      |> Enum.sort()
      # |> IO.inspect()
      |> MapSet.new()
      |> MapSet.size()
    end)
    |> Enum.max()
    |> IO.inspect()

  end

  def fill_until(start, finish, delta) do
    fill_until(start, finish, delta, [])
  end

  def fill_until(start, finish, _, acc) when start == finish do
    [finish | acc]
  end

  def fill_until({x_start, y_start} = start, finish, {x_delta, y_delta}, acc) do
      next = {x_start + x_delta, y_start + y_delta}
      fill_until(next, finish, {x_delta, y_delta}, [start | acc])
  end

  def collect_spaces(grid, tiles, maxes, start) do
    collect_spaces(grid, tiles, maxes, [start], MapSet.new(), [])
  end

  def collect_spaces(_, _, _, [], _, acc) do
    acc
  end

  def collect_spaces(grid, tiles, maxes, level, seen, acc) do
    # IO.inspect(level)
    {nl, ns, a} =  Enum.reduce(level, {[], seen, acc}, fn {dir, loc}, {next_level, seen, acc} ->
      next = get_next(tiles, {dir, loc})
      next_seen = MapSet.put(seen, {dir, loc})
      if next == nil do
        edge = get_edge(dir, loc, maxes)
        if edge == loc do
          {next_level, next_seen, acc}
        else
          {next_level, next_seen, [[loc, edge] | acc]}
        end
      else
        {iter_nl, na}  = get_directions(next, grid, dir)
        |> Enum.reduce({next_level, acc}, fn d, {nl, a} -> {[{d, next}| nl], [[loc, next] | a]} end)
        {Enum.reject(iter_nl, fn x -> MapSet.member?(seen, x) end), next_seen, na}
      end
    end)
    collect_spaces(grid, tiles, maxes, nl, ns, a)
  end


  def get_edge(dir, {x, y}, {max_x, max_y}) do
    case dir do
      :east ->
        {max_x, y}
      :west ->
        {0, y}
      :north ->
        {x, 0}
      :south ->
        {x, max_y}
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
        |> Enum.filter(fn {_, y} -> y == loc_y end)
        |> Enum.sort()
        |> Enum.find(fn {x, _} -> x > loc_x end)
      :west ->
        tiles
        |> Enum.filter(fn {_, y} -> y == loc_y end)
        |> Enum.sort()
        |> Enum.reverse()
        |> Enum.find(fn {x, _} -> x < loc_x end)
      :north ->
        tiles
        |> Enum.filter(fn {x, _} -> x == loc_x end)
        |> Enum.sort()
        |> Enum.reverse()
        |> Enum.find(fn {_, y} -> y < loc_y end)
      :south ->
        tiles
        |> Enum.filter(fn {x, _} -> x == loc_x end)
        |> Enum.sort()
        |> Enum.find(fn {_, y} -> y > loc_y end)
    end
  end

end

Day16.process("real.txt")

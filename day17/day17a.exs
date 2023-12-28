defmodule Day17 do
  alias DialyxirVendored.FilterMap
  @turns %{
    :east => [:north, :south],
    :west => [:north, :south],
    :north => [:east, :west],
    :south => [:east, :west]
  }
  @advance %{:east => {1, 0}, :west => {-1, 0}, :north => {0, -1}, :south => {0, 1}}

  def process(path) do
    grid =
      File.stream!(path)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {line, y}, grid ->
        String.trim(line)
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(grid, fn {char, x}, g ->
          Map.put(g, {x, y}, String.to_integer(char))
        end)
      end)

    maxes = Map.keys(grid)
    |> Enum.reduce({0, 0}, fn {x, y}, {max_x, max_y} ->
      {max(x, max_x), max(y, max_y)}
    end)
    min_distance(grid, maxes)
    |> IO.inspect()
  end

  def min_distance(grid, target) do
    min_distance(grid, target, [{:east, {0, 0}, 0}], %{{0, 0} => 0})
  end

  def min_distance(_, target, [{_, loc, _} | _], state) when loc == target do
    state[loc]
  end

  def min_distance(grid, target, [top | rest], state) do
    {dir, loc, run} = top
    next = get_next(dir, loc, run)
    |> Enum.filter(fn {_, nl, _} -> Map.has_key?(grid, nl) end)
    |> IO.inspect()
    {queue, ns} = Enum.reduce(next, {[], state}, fn {nd, nl, nr}, {queue, state} ->
      distance = state[loc] + grid[nl]
      val = state[nl] || Integer.MAX_VALUE
      if distance <= val do
        {queue ++ [{nd, nl, nr}], Map.put(state, nl, distance)}
      else
        {queue, state}
      end
    end)
    new_queue = Enum.sort(rest ++ queue, fn {_, l1, _}, {_, l2, _}  ->  state[l1] < state[l2]  end)
    dbg(new_queue)
    dbg(ns)
    min_distance(grid, target, new_queue, ns)
  end

  def get_next(dir, loc, run) do
    turns = Enum.map(@turns[dir], fn d -> {d, advance(loc, d), 1} end)
    if run < 3 do
        [{dir, advance(loc, dir), run + 1} | turns]
    else
      turns
    end
  end

  def advance({x, y}, dir) do
    {xd, yd} = @advance[dir]
    {x + xd, y + yd}
  end
end

Day17.process("sample.txt")

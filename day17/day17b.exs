Mix.install([:heap])

defmodule Day17 do
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

    maxes =
      Map.keys(grid)
      |> Enum.reduce({0, 0}, fn {x, y}, {max_x, max_y} ->
        {max(x, max_x), max(y, max_y)}
      end)

    min_distance(grid, maxes)
    |> IO.inspect()
  end

  def min_distance(grid, target) do
    start = {:east, {0, 0}, 0}

    queue =
      Heap.min()
      |> Heap.push({0, start})

    min_distance(grid, target, queue, %{start => 0})
  end

  def min_distance(grid, target, queue, state) do
    # IO.inspect(queue)
    {{heat, top}, rest} = Heap.split(queue)
    {dir, loc, run} = top

    if loc == target and run >= 4 do
      state[top]
    else
      next =
        get_next(dir, loc, run)
        |> Enum.filter(fn {_, nl, _} -> Map.has_key?(grid, nl) end)

      # IO.inspect(next)

      # |> IO.inspect()
      {nq, ns} =
        Enum.reduce(next, {rest, state}, fn {_, nl, _} = ns, {q, state} ->
          distance = state[top] + grid[nl]
          val = state[ns] || Integer.MAX_VALUE
          # IO.puts("distance: #{distance}, val: #{val}")
          # IO.inspect(nl)
          if distance < val do
            {Heap.push(q, {distance, ns}), Map.put(state, ns, distance)}
          else
            {q, state}
          end
        end)

      min_distance(grid, target, nq, ns)
    end
  end

  def get_next(dir, loc, run) do
    turns = Enum.map(@turns[dir], fn d -> {d, advance(loc, d), 1} end)

    cond do
      run < 4 ->   [{dir, advance(loc, dir), run + 1} ]
      run < 10 ->  [{dir, advance(loc, dir), run + 1} | turns]
      true -> turns
    end
  end

  def advance({x, y}, dir) do
    {xd, yd} = @advance[dir]
    {x + xd, y + yd}
  end
end

Day17.process("real.txt")

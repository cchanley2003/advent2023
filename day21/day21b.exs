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

    list = stepIncrements = 0..3
    |> Enum.map(fn incr ->
      trunc((131 / 2) + (131 * incr)) end)
    |> Enum.map(fn steps ->
      walk(grid, [{start, 0}], steps, 0, [], MapSet.new())
      |> Enum.filter(fn {_, s} -> rem(s, 2) == 0 end)
      |> length()
    end)

    list_of_lists = delta_all_lists(list, [list])

    # numStepCycles = trunc((26501365 - 65) / 131)
    # get_count(list_of_lists, numStepCycles)


    # my $dsize = 2 × $!width;
    # my $num-dgrids = $steps div $dsize;
    # my $rest = $steps % $dsize;

    # my $y0 = self.reachable-after(0×$dsize + $rest);
    # my $y1 = self.reachable-after(1×$dsize + $rest);
    # my $y2 = self.reachable-after(2×$dsize + $rest);

    # my $a = ($y0 - 2*$y1 + $y2) / 2;
    # my $b = (4*$y1 - 3*$y0 - $y2) / 2;
    # my $c = $y0;

    # sub f($x) { $a*$x² + $b*$x + $c }
  end

  def get_count(list_of_lists, goal) do
    last = hd(Enum.reverse(list_of_lists))
    IO.puts("Last: #{length(last)} and goal #{goal}")
    if length(last) == goal do
      hd(Enum.reverse(last))
    else
      next = list_of_lists
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [a, b] ->
        [hd(Enum.reverse(a)) + hd(Enum.reverse(b)) | Enum.reverse(b)]
      end)
      |> Enum.map(fn l -> Enum.reverse(l) end)
      |> List.insert_at(0, [0])
      get_count(next, goal)
    end
  end

  def walk(_, _, goal, step, visited, seen) when goal == step do
    visited
  end

  def delta_list(list) do
    list
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] ->
      b - a
    end)
  end

  def walk(grid, locs, goal, step, visited, seen) do
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
  def delta_all_lists(list, acc) do
    dbg(list)
    if length(list) == 0 do
      [[0] | tl(acc)]
    else
      delta = delta_list(list)
      delta_all_lists(delta, [delta | acc])
    end
  end

  def get_next(grid, {ox, oy}) do
    x = rem(rem(ox, 131) + 131, 131)
    y = rem(rem(oy, 131) + 131, 131)
    Enum.reduce(@steps, [], fn step, acc ->
      {dx, dy} = step
      nl = {x + dx, y + dy}
      if Map.get(grid, nl) != "#" do
        [{ox + dx, oy + dy} | acc]
      else
        acc
      end
    end)
  end

end

Day21a.process("real.txt")
|> IO.inspect()

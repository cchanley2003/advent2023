defmodule Day25 do
  def process(path) do
    edges = File.stream!(path)
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn line -> String.split(line, ": ") end)
    |> Enum.flat_map(fn [node, dests] ->
       String.split(dests, " ")
       |> Enum.map(fn dest -> {node, dest} end)
    end)
    |> Enum.uniq()
    |> IO.inspect()

    vertices = edges
    |> Enum.flat_map(fn {node, dest} -> [node, dest] end)
    |> Enum.uniq()

    {vertices, edges}

    edges_to_cut = cut_of_three(vertices, edges) |> MapSet.new()

    distinct = edges
    |> Enum.filter(fn edge -> not(MapSet.member?(edges_to_cut, edge)) end)

    group1 = create_groups([hd(distinct)], distinct, MapSet.put(MapSet.new(), hd(distinct)))
    group2 = MapSet.new(distinct) |> MapSet.difference(group1)

    g1 = group1
    |> Enum.flat_map(fn {s, d} -> [s, d] end)
    |> Enum.uniq()

    g2 = group2
    |> Enum.flat_map(fn {s, d} -> [s, d] end)
    |> Enum.uniq()

    length(g1) * length(g2)
  end

  def create_groups([], edges, seen) do
    seen
  end

  def create_groups(next , edges, seen) do
    nn = next
    |> Enum.flat_map(fn edge -> get_next(edge, edges, seen) end)
    create_groups(nn, edges, MapSet.union(seen, MapSet.new(next)))
  end

  def get_next({s, d}, edges, seen) do
    edges
    |> Enum.filter(fn {s1, d1} -> s1 == s or d1 == s or s1 == d or d1 == d end)
    |> Enum.reject(fn edge -> MapSet.member?(seen, edge) end)
  end

  def cut_of_three(vertices, edges) do
    res = kargerMinCut(vertices, edges)
    IO.puts("Result is #{length(res)}")
    if(length(res) == 3) do
      IO.inspect(res)
      res
    else
      cut_of_three(vertices, edges)
    end
  end

  def kargerMinCut(vertices, edges) do
    subsets = vertices
    |> Enum.map(fn v -> {v, {v, 0}} end)
    |> Map.new()

    kargerMinCut(vertices, edges, subsets, length(vertices))
  end

  def kargerMinCut(vertices, edges, subsets, 2) do
    edges
    |> Enum.map(fn {s, d} -> {{s, elem(find(subsets, s), 0)}, {d, elem(find(subsets, d), 0)}} end)
    |> Enum.filter(fn {{_, s}, {_, d}} -> s != d end)
    |> Enum.map(fn {{s, _}, {d, _}} -> {s, d} end)

  end

  def kargerMinCut(vertices, edges, subsets, vert_length) do
    random_edge = Enum.random(edges)
    {src, dest} = random_edge
    {s1, subsets} = find(subsets, src)
    {s2, subsets} = find(subsets, dest)
    if s1 == s2 do
      kargerMinCut(vertices, edges, subsets, vert_length)
    else
      subsets = union(subsets, s1, s2)
      kargerMinCut(vertices, edges, subsets, vert_length - 1)
    end
  end

  def union(subsets, x, y) do
    {xroot, subsets} = find(subsets, x)
    {yroot, subets} = find(subsets, y)
    {_, x_rank} = subsets[xroot]
    {_, y_rank} = subsets[yroot]
    cond do
      x_rank < y_rank ->
        Map.put(subsets, xroot, {yroot, x_rank})
      x_rank > y_rank ->
        Map.put(subsets, yroot, {xroot, y_rank})
      true ->
        Map.put(subsets, yroot, {xroot, y_rank + 1})
    end
  end

  def find(subsets, target) do
    {parent, rank} = subsets[target]
    sub = if parent == target do
      subsets
    else
      {parent, ns} = find(subsets, parent)
      Map.put(ns, target, {parent, rank})
    end
    {elem(sub[target], 0), sub}
  end
end

Day25.process("real.txt")
|> IO.inspect()

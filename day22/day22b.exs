Mix.install([:aja])

defmodule Day22 do
  alias Aja.Vector, as: Vec
  def process(path) do
    bricks =
      File.stream!(path)
      |> Enum.map(&String.trim/1)
      |> Enum.map(fn s -> String.split(s, "~") end)
      |> Enum.map(fn l -> Enum.map(l, &to_int_list/1) end)
      |> Enum.map(&Enum.sort/1)
      |> Enum.map(&to_brick/1)
      |> Enum.sort(fn a, b -> List.last(List.last(a)) < List.last(List.last(b)) end)
      |> Enum.map(fn x -> Enum.map(x, &List.to_tuple/1) end)

    pile = build_pile(bricks)
    dbg(pile)
    bricks = Map.values(pile) |> Enum.uniq()
    cascade_effect(bricks, pile)
  end

  def cascade_effect(bricks, pile) do
    cascade_effect(bricks, pile,  0)
  end

  def cascade_effect([], pile, acc) do
    acc
  end

  def cascade_effect([brick | rest], pile, acc) do
    # IO.puts("Impact")

    # dbg(brick)
    impact = dis_impact(brick, pile)
    # dbg(impact)
    cascade_effect(rest, pile, acc + impact)
  end

  def dis_impact([], pile, acc) do
    MapSet.size(acc) - 1
  end

  def dis_impact(brick, sand_pile) do
    bricks = [brick]
    dis_impact(bricks, sand_pile, MapSet.new(bricks))
  end

  def dis_impact([brick | rest], pile, fallen) do
    # dbg(brick)
    above =
      Enum.filter(brick, fn {x, y, z} -> Map.has_key?(pile, {x, y, z + 1}) end)
      # |> IO.inspect()
      |> Enum.map(fn  {x, y, z} -> Map.get(pile, {x, y, z + 1}) end)
      |> Enum.uniq()
      |> Enum.filter(fn x -> x != brick end)

      # dbg(above)

      next = above
      |> Enum.filter(fn b -> MapSet.new(bricks_below(b, pile)) |> MapSet.difference(fallen) |> MapSet.size() == 0 end)
      # dbg(next)
      dis_impact(next ++ rest, pile, MapSet.union(fallen, MapSet.new(next)))
  end

  def bricks_below(brick, pile) do
    Enum.map(brick, fn {x, y, z} -> Map.get(pile, {x, y, z - 1}) end)
    |> Enum.filter(fn x -> x != nil end)
    |> Enum.uniq()
    |> Enum.filter(fn x -> x != brick end)
    # |> IO.inspect()
  end

  def build_pile(bricks) do
    build_pile(bricks, {Map.new(), Map.new()})
  end

  def build_pile([], {topo_map, sand_map}) do
    sand_map
  end

  def build_pile([brick | rest], {topo_map, sand_map}) do
    pile_top_intersect =
      Enum.map(brick, fn {x, y, _} -> Map.get(topo_map, {x, y}, 1) end)
      |> Enum.max()

    drop_amnt = Enum.map(brick, fn {_, _, z} -> z - pile_top_intersect end) |> Enum.min()

    z_drop = Enum.map(brick, fn {x, y, z} -> {x, y, z - drop_amnt} end)

    topo_map = Enum.reduce(z_drop, topo_map, fn {x, y, z}, tp -> Map.put(tp, {x, y}, z + 1) end)
    sand_map = Enum.reduce(z_drop, sand_map, fn sand, sm -> Map.put(sm, sand, z_drop) end)
    build_pile(rest, {topo_map, sand_map})
  end


  def to_int_list(str) do
    String.split(str, ",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
  end

  def to_brick([a, b]) do
    vec_a = Vec.new(a)
    vec_b = Vec.new(b)

    0..2
    |> Enum.reduce([a], fn i, acc ->
      if(vec_a[i] == vec_b[i]) do
        acc
      else
        vec_a[i]..vec_b[i]
        |> Enum.map(fn x -> vec_a |> Vec.replace_at(i, x) |> Aja.Enum.to_list() end)
      end
    end)
    |> Enum.sort(fn a, b -> List.last(a) < List.last(b) end)
  end
end

Day22.process("real.txt")
|> IO.inspect()

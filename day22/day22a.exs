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

    build_pile(bricks)
    |> IO.inspect()
    |> count_disintegrates()
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

  def count_disintegrates(sand_map) do
    Map.values(sand_map)
    |> Enum.uniq()
    |> Enum.reduce(0, fn brick, acc ->
      if can_disintegrate(sand_map, brick) do
        1 + acc
      else
        acc
      end
    end)
  end

  def can_disintegrate(sand_map, brick) do
    above =
      Enum.filter(brick, fn {x, y, z} -> Map.has_key?(sand_map, {x, y, z + 1}) end)
      |> Enum.map(fn  {x, y, z} -> Map.get(sand_map, {x, y, z + 1}) end)
      |> Enum.uniq()
      |> Enum.filter(fn x -> x != brick end)

    held =
      above
      |> Enum.filter(fn above_brick ->
        Enum.any?(above_brick, fn {x, y, z} ->
          step_down = {x, y, z - 1}
          down_brick = Map.get(sand_map, step_down)
          down_brick != nil and down_brick != above_brick and down_brick != brick
        end)
      end)


    held == above or above == []
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

Day22.process("sample.txt")
|> IO.inspect()

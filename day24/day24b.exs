defmodule Day24 do

  @min 200000000000000
  @max 400000000000000
  def process(path) do
    File.stream!(path)
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn s -> String.split(s, " @ ") end)
    |> Enum.map(fn splits -> Enum.map(splits, &csv_to_ints/1) |> Enum.map(&List.to_tuple/1) end)
    |> Enum.map(&List.to_tuple/1)
    |> combinations()
    |> Enum.filter(&can_intersect/1)
    |> Enum.map(&intersection/1)
    |> IO.inspect()
    |> Enum.filter(fn x -> x != nil end)
    |> Enum.filter(fn {x, y, _} -> x >= @min and x <= @max and y >= @min and y <= @max end)
    |> length()
    |> IO.inspect()

  end

  def can_intersect({a, b}) do
    denom(a, b) != 0
  end

  def intersection({a, b}) do
    denom = denom(a, b)

    {{ax, ay, _}, {adx, ady, _}} = a
    {{bx, by, _}, {bdx, bdy, _}} = b

    t = ((bx - ax) * bdy - (by - ay) * bdx) / denom
    u = ((bx - ax) * ady - (by - ay) * adx) / denom

    # Intersection is prior to the stones' initial position (negative
    # time).
    if t < 0 or u < 0 do
      nil
    else
      {ax + t * adx, ay + t * ady, 0}
    end
  end

  def denom(a, b) do
    {_, {adx, ady, _}} = a
    {_, {bdx, bdy, _}} = b
    adx * bdy - ady * bdx
  end


  def combinations(list) do
    list
    |> Enum.with_index()
    |> Enum.flat_map(fn {elem, index} ->
      list
      |> Enum.drop(index + 1)
      |> Enum.map(fn other_elem -> {elem, other_elem} end)
    end)
  end

  def csv_to_ints(s) do
    String.split(s, ", ")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)

  end
end

Day24.process("real.txt")

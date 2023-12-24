Mix.install([:aja])

defmodule Day13 do
  alias Aja.Vector, as: Vec
  import Aja

  def process(path) do
    File.stream!(path)
    |> Enum.chunk_by(fn line -> line |> String.trim() |> String.length() == 0 end)
    |> Enum.map(fn lines -> handle_chunk(lines) end)
    |> Enum.sum()
    |> IO.inspect()
  end

  def handle_chunk(lines) do
    grid =
      lines
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {line, y}, grid ->
        String.trim(line)
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(grid, fn {char, x}, g ->
          Map.put(g, {x, y}, char)
        end)
      end)

    {max_x, max_y} =
      Map.keys(grid)
      |> Enum.reduce({0, 0}, fn {x, y}, {max_x, max_y} ->
        {max(x, max_x), max(y, max_y)}
      end)

    # Convert grid to a list of lists along x axis
    vert_grid =
      Vec.new(0..max_x)
      |> Enum.map(fn x ->
        0..max_y
        |> Enum.reduce(Vec.new(), fn y, acc ->
          Vec.append(acc, Map.get(grid, {x, y}, " "))
        end)
      end)

    # Convert grid to a list of lists along y axis
    horiz_grid =
      Vec.new(0..max_y)
      |> Enum.map(fn y ->
        0..max_x
        |> Enum.reduce(Vec.new(), fn x, acc ->
          Vec.append(acc, Map.get(grid, {x, y}, " "))
        end)
      end)

    v_p = find_potential_reflection(vert_grid)

    h_p = find_potential_reflection(horiz_grid)

    h_matches =
      Enum.filter(h_p, fn x -> check_for_reflection(horiz_grid, x) end)
    dbg(h_matches)

    v_matches =
      Enum.filter(v_p, fn x -> check_for_reflection(vert_grid, x) end)
    dbg(v_matches)
    head(v_matches) + (100 * head(h_matches))
  end

  def head([]), do: 0
  def head([head | _tail]), do: head
  # From the boundary expand out until we hit the end or no longer reflect
  def check_for_reflection(list, potential_boundary) do
    check_for_reflection(list, potential_boundary, 1, 0)
  end

  def check_for_reflection(list, potential_boundary, step, diff_count) do
    v = Vec.new(list)
    left = potential_boundary - step
    right = potential_boundary + step - 1

    if left < 0 or right > vec_size(v) - 1 do
      diff_count == 1
    else
      diffs = Enum.zip(v[left], v[right])
      |> Enum.reduce(0, fn {x, y}, acc ->
        if x != y do
          acc + 1
        else
          acc
        end
      end)
      new_diff = diff_count + diffs
      if new_diff <= 1 do
        check_for_reflection(list, potential_boundary, step + 1, new_diff)
      else
        false
      end
    end
  end

  def find_potential_reflection(list), do: find_potential_reflection(list, 1, [])

  def find_potential_reflection([x], _, loc), do: loc

  def find_potential_reflection([x, y | rem], count, loc) do
    diffs = Enum.zip(x, y)
    |> Enum.reduce(0, fn {x, y}, acc ->
      if x != y do
        acc + 1
      else
        acc
      end
    end)
    if diffs <= 1 do
      find_potential_reflection([y | rem], count + 1, [count | loc])
    else
      find_potential_reflection([y | rem], count + 1, loc)
    end
  end
end

Day13.process("real.txt")

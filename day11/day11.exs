Mix.install([:aja])
defmodule Day11 do
  def process_file(path) do
    {mx, my, gal_locs} = File.stream!(path)
    |> Enum.with_index()
    |> Enum.reduce({0, 0, []}, fn {line, index}, max_and_locs ->
      process_line(line, index, max_and_locs )
    end)

    combos = all_combinations(gal_locs)

    x_gaps =
      gal_locs
      |> Enum.map(fn {x, _} -> x end)
      |> Enum.sort()
      |> find_gaps()
      |> MapSet.new()

    y_gaps =
      gal_locs
      |> Enum.map(fn {_, y} -> y end)
      |> Enum.sort()
      |> find_gaps()
      |> MapSet.new()

    x_delta = generate_delta(mx, x_gaps)
    y_delta = generate_delta(my, y_gaps)

    combos
    |> Enum.map(fn {a, b} ->
      calc_distance(a, b, x_delta, y_delta)
    end)
    |> Enum.sum()
    |> IO.puts()
  end

  defp calc_distance({x, y}, {nx, ny}, delta_x, delta_y) do
    xd= delta_x[x]
    yd = delta_y[y]
    nxd = delta_x[nx]
    nyd = delta_y[ny]
    x_dist = abs((x + xd) - (nx + nxd))
    y_dist = abs((y + yd) - (ny + nyd))
    x_dist + y_dist
  end
  
  def all_combinations(list) do
    list
    |> Enum.with_index()
    |> Enum.flat_map(fn {elem1, idx1} ->
      Enum.drop(list, idx1 + 1)
      |> Enum.map(fn elem2 -> {elem1, elem2} end)
    end)
  end

  defp process_line(line, y, max_and_locs) do
    line
    |> String.trim()
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(max_and_locs, fn {el, x}, {max_x, max_y, locs} ->
      {max(max_x, x + 1), max(max_y, y + 1), add_galaxy(locs, el, x, y)}
    end)
  end

  def generate_delta(max, gaps) do
    0..(max - 1)
    |> Enum.reduce({Aja.Vector.new(), 0}, fn loc, {vec, prev} ->
      next = if MapSet.member?(gaps, loc), do: prev + 999999 , else: prev
      {Aja.Vector.append(vec, next), next}
    end)
    |> elem(0)
  end

  def find_gaps(list) do
    list
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.flat_map(fn [a, b] ->
      if b - a > 1, do: Enum.to_list(a + 1..b - 1), else: []
    end)
  end

  defp add_galaxy(locs, el, x, y) do
    if el == "#" do
      [{x, y} | locs]
    else
      locs
    end
  end
end


Day11.process_file("real.txt")

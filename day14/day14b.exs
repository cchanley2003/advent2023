Mix.install([:aja])

defmodule Day14 do
  alias Aja.Vector, as: Vec

  def process(path) do
    grid =
      File.stream!(path)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {line, y}, grid ->
        String.trim(line)
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(grid, fn {char, x}, g ->
          Map.put(g, {x, y}, char)
        end)
      end)

    {max_x, max_y} = maxes =
      Map.keys(grid)
      |> Enum.reduce({0, 0}, fn {x, y}, {max_x, max_y} ->
        {max(x, max_x), max(y, max_y)}
      end)

    regular_grid =
      0..max_y
      |> Enum.map(fn y ->
        0..max_x
        |> Enum.reduce([], fn x, acc ->
          [Map.get(grid, {x, y}, " ") | acc]
        end)
      end)
      |> Enum.map(&Enum.reverse/1)
      |> IO.inspect()

    {cycle_start, cycle_end} = find_repeat(regular_grid, {max_x, max_y})
    |> IO.inspect()

    cycle_length = cycle_end - cycle_start
    cycle_rem = rem(1000000000 - cycle_start, cycle_length)
    IO.puts("cycle_rem: #{cycle_rem}")
    1..(cycle_end + cycle_rem)
    |> Enum.reduce(regular_grid, fn _num, grid ->
      run_cycle(grid, {max_x, max_y})
      # g
      # |> convert_to_map()
      # |> rotate_map_toList(maxes)
      # |> Enum.map(&sum_train/1)
      # |> Enum.sum()
      # |> IO.inspect()
      # IO.puts(" ")
      # g
    end)
    |> convert_to_map()
    |> rotate_map_toList(maxes)
    |> Enum.map(&sum_train/1)
    |> Enum.sum()
  end

  def find_repeat(grid, maxes) do
    find_repeat(grid, maxes, %{}, 1)
  end

  def find_repeat(grid, maxes, cycle_map, cycle_count) do
    if Map.has_key?(cycle_map, grid) do
      {cycle_map[grid], cycle_count}
    else
      next_grid = run_cycle(grid, maxes)
      find_repeat(next_grid, maxes, Map.put(cycle_map, grid, cycle_count), cycle_count + 1)
    end
  end


  def run_cycle(grid, maxes) do
    0..3
    |> Enum.reduce(grid, fn _num, grid ->
      rotate_grid(grid, maxes)
    end)
  end

  def rotate_grid(grid, maxes) do
    grid
    |> convert_to_map()
    |> rotate_map_toList(maxes)
    |> Enum.map(&adjust_train/1)
  end

  def convert_to_map(grid) do
    grid
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {level, y}, grid ->
      level
      |> Enum.with_index()
      |> Enum.reduce(grid, fn {char, x}, g ->
        Map.put(g, {x, y}, char)
      end)
    end)
  end

  def rotate_map_toList(grid, {max_x, max_y}) do
    0..max_x
    |> Enum.map(fn x ->
      0..max_y
      |> Enum.reduce([], fn y, acc ->
        [Map.get(grid, {x, y}, " ") | acc]
      end)
    end)
  end

  def sum_train(train) do
    train
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {char, index}, acc ->
      if char == "O" do
        acc + index
      else
        acc
      end
    end)
  end

  def adjust_train(train) do
    adjust_train(Vec.new(train), {0, 0, false})
  end

  def adjust_train(train_vec, {trail_pt, lead_pt, gathering}) do
    if lead_pt >= Vec.size(train_vec) do
      Vec.to_list(train_vec)
    else
      lead_char = train_vec[lead_pt]
      {next_state, next_vec} =
        cond do
          lead_char == "." and gathering == false ->
            {{lead_pt + 1, lead_pt + 1, false}, train_vec}

          lead_char == "O" and gathering == false ->
            {{lead_pt, lead_pt + 1, true}, train_vec}

          lead_char == "O" and gathering == true ->
            {{trail_pt, lead_pt + 1, true}, train_vec}

          lead_char == "." and gathering == true ->
            {{trail_pt + 1, lead_pt + 1, true},
             Vec.replace_at(train_vec, lead_pt, "O") |> Vec.replace_at(trail_pt, ".")}
          lead_char == "#" ->
            {{lead_pt + 1, lead_pt + 1, false}, train_vec}
        end
      adjust_train(next_vec, next_state)
    end
  end
end

Day14.process("real.txt")
|> IO.inspect()

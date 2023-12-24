defmodule Day14 do
  def process(path) do
    grid = File.stream!(path)
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

      rotate_grid =
        0..max_x
        |> Enum.map(fn x ->
          0..max_y
          |> Enum.reduce([], fn y, acc ->
            [ Map.get(grid, {x, y}, " ") | acc ]
          end)
          |> Enum.with_index()
      end)

      Enum.map(rotate_grid, fn l ->
        IO.inspect(l)
        sum_train(l)
      end)
      |> Enum.sum()
  end

  def sum_train(train) do
    sum_train(train, {0, 0})
  end

  def sum_train([], {train_size, sum}) do
    sum
  end

  def sum_train([ {el, index} | tail], {train_size, sum}) do
    state = case el do
      "." -> {train_size, sum + train_size}
      "O" -> {train_size + 1, sum  + (index + 1)}
      "#" -> {0, sum}
    end
    sum_train(tail, state)
  end
end

Day14.process("real.txt")
|> IO.inspect()

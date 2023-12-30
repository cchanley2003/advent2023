defmodule Day18a do

  @to_dir %{"0" => "R", "1" => "D", "2" => "L", "3" => "U"}
  @dirs %{"R" => {1, 0}, "L" => {-1, 0}, "U" => {0, -1}, "D" => {0, 1}}

  def process(path) do
    boundary = File.stream!(path)
    |> Enum.map(fn line ->
      res = line
      |> String.trim()
      |> String.split(" ")
      |> List.last()
      {String.at(res, -2), String.slice(res, 2..-3)}
    end)
    |> Enum.map(fn {x, y} -> {@to_dir[x], String.to_integer(y, 16)}    end)
    |> IO.inspect()

    dis = boundary
    |> Enum.reduce(0, fn {dir, steps}, acc ->
      acc + steps
    end)
    |> IO.inspect()

    boundary =  boundary
    |> Enum.reduce([{0, 0}], fn {dir, steps}, [{x, y} = latest | acc] ->
      {dx, dy} = @dirs[dir]
      [{x + dx * steps, y + dy * steps}, latest | acc]
    end)
    |> Enum.reverse()
    |> IO.inspect()


    a = area(tl(boundary)) |> IO.inspect()

    a + dis / 2 + 1
  end

  def area(list) do
    area(list, 0)
  end

  def area([{x, y}], acc) do
    acc / 2
  end
  def area([{x, y}, {x1, y1} = trail | rest], acc) do
    # IO.inspect({x, y, x1, y1, acc})
    area([trail | rest], (x * y1) - (x1 * y) + acc)
  end
end

Day18a.process("real.txt")
|> IO.inspect()

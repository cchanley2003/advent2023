# Define your range
top = 30
range = 0..top

defmodule Day6 do
  def search(record, bottom, top, total_time) do
    IO.puts("Searching for #{bottom} to #{top}")
    middle = trunc((top - bottom) / 2) + bottom
    res = equation(middle, total_time)
    resPlus = equation(middle + 1, total_time)
    if res <= record and resPlus > record do
      middle + 1
    else
      if res > record and resPlus > record do
        search(record, bottom, middle, total_time)
      else
        search(record, middle, top, total_time)
      end
    end
  end

  def equation(x, time) do
    diff = time - x
    x * diff
  end
end

[{49979494, 263153213781851}]
|> Enum.map(fn {time, record} ->
  num = Day6.search(record, 0, trunc(time / 2), time)
  res  = (trunc(time /2 ) - num) * 2
  if rem(time, 2) == 1 do
    res + 2
  else
    res + 1
  end
end)
|> Enum.reduce(1, fn x, acc -> x * acc end)
|> IO.inspect()

start = trunc(top / 2)

# Day6.search(9, 0, 3, 7) |> IO.puts()
# Day6.search(40, 0,8, 15)|> IO.puts()
# Day6.search(200, 0, 15, 30) |> IO.puts()

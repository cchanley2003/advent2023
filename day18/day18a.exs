defmodule Day18a do

  def process(path) do
    File.stream!(path)
    |> Enum.map(fn line ->
      line
      |> String.trim()
      |> String.split(" ")
    end)
    |> Enum.map(fn [x, y | _] -> {x, String.to_integer(y)}    end)
    |> IO.inspect()
  end
end

Day18a.process("sample.txt")

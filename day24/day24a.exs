defmodule Day24 do
  def process(path) do
    File.stream!(path)
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn s -> String.split(s, " @ ") end)
    |> Enum.map(fn splits -> Enum.map(splits, &csv_to_ints/1) |> Enum.map(&List.to_tuple/1) end)
    |> IO.inspect()


  end

  def csv_to_ints(s) do
    String.split(s, ", ")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)

  end
end


Day24.process("sample.txt")

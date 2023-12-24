defmodule Day15 do

  def process(line) do
    line
    |> String.trim()
    |> String.split(",")
    |> IO.inspect()
    |> Enum.map(&Day15.hash_string/1)
    |> IO.inspect()
    |> Enum.sum()
    |> IO.inspect()
  end

  def hash_string(str) do
    IO.inspect(str)
    str
    |> to_char_list()
    |> Enum.reduce(0, fn char, acc ->
      rem(((char + acc) * 17), 256)
    end)
  end
end

line = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"
Day15.hash_string("HASH")
|> IO.inspect()

Day15.process(File.read!("real.txt"))

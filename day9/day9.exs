defmodule Day9 do

  def process_file(file_path) do
    lists = file_path
    |> load_file()

    lists
    |> dbg()
    |> Enum.map(fn l -> delta_all_lists(l, [l]) end)
    |> Enum.map(fn l ->
      l
      |> dbg()
      |> Enum.reduce(0, fn l, acc ->
          dbg(l)
          e = l
        #  |> Enum.reverse()
          |> hd()
          e - acc
          #  acc + e
        end)
      end)
    |> Enum.sum()
    |> dbg()

  end

  def load_file(path) do
    File.read!(path)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn s -> String.split(s, " ") end)
    |> Enum.map(fn l -> Enum.map(l, &String.to_integer/1) end)
  end

  def delta_list(list) do
    list
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] ->
      b - a
    end)
  end

  def delta_all_lists(list, acc) do
    if Enum.all?(list, fn el ->  el == 0 end) do
      acc
    else
      delta = delta_list(list)
      delta_all_lists(delta, [delta | acc])
    end
  end
end


Day9.process_file("real.txt")
|> dbg()

# Day9.delta_all_lists([0, 3, 6, 9, 12, 15], [])
# |> dbg()

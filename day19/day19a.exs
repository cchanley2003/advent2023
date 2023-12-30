defmodule Day19a do
  def process(path) do
    contents = File.read!(path)
    String.split(contents, "\n\n")
    |> Enum.map(fn line ->
      String.split(line, "\n")
    end)
  end
end

Day19a.process("sample.txt")
|> IO.inspect()

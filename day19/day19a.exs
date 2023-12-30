defmodule Day19a do
  def process(path) do
    [rules, input] = File.read!(path)
    |> String.split("\n\n")
    |> Enum.map(fn line ->
      String.split(line, "\n")
    end)

    rules
    |> Enum.map(fn line ->
      # Capture "px{a<2006:qkq,m>2090:A,rfg}
     tl(Regex.run(~r/(.*){(.*)}/, line))
    end)
    |> Enum.map(fn [rule_name, rules] ->
      {rule_name, rules |> String.split(",")}
    end)
  end
end

Day19a.process("sample.txt")
|> IO.inspect()

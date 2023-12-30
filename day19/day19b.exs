defmodule Day19a do

  greater_than = &(&1 > &2)
  less_than = &(&1 < &2)

  def process(path) do
    [rules, _] = File.read!(path)
    |> String.split("\n\n")
    |> Enum.map(fn line ->
      String.split(line, "\n")
    end)

    parsed_rules = rules
    |> Enum.map(fn line ->
      # Capture "px{a<2006:qkq,m>2090:A,rfg}
     tl(Regex.run(~r/(.*){(.*)}/, line))
    end)
    |> Enum.map(fn [rule_name, rules] ->
      {rule_name, rules |> String.split(",")}
    end)
    |> Enum.map(fn {rule_name, rules} ->
      {rule_name, rules |> Enum.map(&convert/1)}
    end)
    |> Map.new()
    |> IO.inspect()

  end

  def walk_rules(rules, next, rule_id) do
    rule = Map.get(rules, rule_id)
    case walk_rule(rule, i) do
      :accept -> i |> Map.values() |> Enum.sum()
      :reject -> 0
      {:dest, dest} -> walk_rules(rules, i, dest)
    end
  end

  def walk_rules(rules) do
    walk_rules(rules, [{{1, 4000}, {:dest, "in"}}] )
  end

  def walk_rule([{v, op, n, dest} | rules], i) do
    lookup = Map.get(i, v)
    cond do
      op.(lookup, n) -> dest
      true -> walk_rule(rules, i)
    end
  end

  def walk_rule([rule], _) do
    rule
  end

  def convert(str) do
    cond do
      str == "R" -> :reject
      str == "A" -> :accept
      String.contains?(str, ":") -> convert_rule(str)
      true -> {:dest, str}
    end
  end

  def convert_rule(rule) do
    [check, dest] = String.split(rule,":")
    dest = convert(dest)
    if String.contains?(check, "<") do
      [arg, val] = String.split(check, "<")
      {arg, &(&1 < &2), String.to_integer(val), dest}
    else
      [arg, val] = String.split(check, ">")
      {arg, &(&1 > &2), String.to_integer(val), dest}
    end
  end
end

Day19a.process("real.txt")
|> IO.inspect()

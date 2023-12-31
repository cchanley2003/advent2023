defmodule Day19a do

  greater_than = &(&1 > &2)
  less_than = &(&1 < &2)

  def process(path) do
    [rules, input] = File.read!(path)
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

    parsed_input = input
    |> Enum.map(fn line ->
      line
      |> String.slice(1..-2)
    end)
    |> Enum.map(fn line ->
      line
      |> String.split(",")
    end)
    |> Enum.map(fn line ->
      line
      |> Enum.map(fn x ->
        [var, num] = String.split(x, "=")
        {var, String.to_integer(num)}
      end)
    end)
    |> Enum.map(&Map.new/1)

    # walk_rules(parsed_rules, hd(tl(parsed_input)))
    Enum.map(parsed_input, fn i ->
      walk_rules(parsed_rules, i)
    end)
    |> IO.inspect()
    |> Enum.sum()
  end

  def walk_rules(rules, i, rule_id) do
    dbg(rule_id)
    # dbg(rules)
    rule = Map.get(rules, rule_id)
    case walk_rule(rule, i) do
      :accept -> i |> Map.values() |> Enum.sum()
      :reject -> 0
      {:dest, dest} -> walk_rules(rules, i, dest)
    end
  end

  def walk_rules(rules, i) do
    walk_rules(rules, i,"in")
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

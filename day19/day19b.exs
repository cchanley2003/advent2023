defmodule Day19a do

  def greater_than(input, var, num) do
    {start, finish} = Map.get(input, var)
    # split range via num
    cond do
      start <= num and finish > num -> [Map.put(input, var, {num + 1, finish}), Map.put(input, var, {start, num})]
      true -> [nil, input]
    end
  end

  def less_than(input, var, num) do
    {start, finish} = Map.get(input, var)
    # split range via num
    cond do
      start < num and finish >= num -> [Map.put(input, var, {start, num - 1}), Map.put(input, var, {num, finish})]
      true -> [nil, input]
    end
  end

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

    walk_rules(parsed_rules)

  end

  def walk_rules(rules, next) do
    IO.inspect(next)
    Enum.map(next,fn {i, dest}->
      case dest do
        :accept ->
          sum = i
          |> Map.values()
          |> Enum.map(fn {s, f} -> f - s + 1 end)
          |> Enum.reduce(1, &Kernel.*(&1, &2))
          sum
        :reject -> 0
        {:dest, dest} ->
          next = get_next(rules, dest, i)
          walk_rules(rules, next)
      end
    end)
    |> Enum.sum()
  end

  def walk_rules(rules) do
    walk_rules(rules, [{%{"x" => {1, 4000},
                          "m" => {1, 4000},
                          "a" => {1, 4000},
                          "s" => {1, 4000},
                         },
                        {:dest, "in"}}])
  end

  def get_next(rules, dest, input) do
    IO.puts("handling rule #{dest}")
    IO.inspect(input)
    IO.inspect(rules)
    rule = Map.get(rules, dest)
    get_next_for_rule(rule, input, [])
  end

  def get_next_for_rule([{arg, func, val, dest} | rest], input, acc) do
    [match, no_match] = func.(input, arg, val)
    acc = if match do
      [{match, dest} | acc]
    else
      acc
    end
    get_next_for_rule(rest, no_match, acc)
  end

  def get_next_for_rule([dest], input, acc) do
    [{input, dest} | acc]
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
      {arg, &less_than/3, String.to_integer(val), dest}
    else
      [arg, val] = String.split(check, ">")
      {arg, &greater_than/3, String.to_integer(val), dest}
    end
  end
end

Day19a.process("real.txt")
|> IO.inspect()

defmodule Day20a do
  def process(path) do
    parsed = File.stream!(path)
    |> Enum.map(fn line ->
      line
      |> String.trim()
      |> String.split(" -> ")
    end)
    |> Enum.map(fn [pre, post] ->
      {type, val} = get_type(pre)
      {val, {type, String.split(post, ", ")}} end)
    |> Map.new()

    parsed
    |> Enum.filter(fn {val, {type, _}} -> type == :flipflop end)
    |> IO.inspect()
    |> Enum.map(fn {val, {_, cons}} -> {val, Enum.map(cons, fn c -> {c, :off} end) |> Map.new()} end)
    |> IO.inspect()

    parsed
    |> Enum.filter(fn {val, {type, _}} -> type == :conjunction end)
    |> Enum.map(fn {val, {_, cons}} -> {val, get_connections(parsed, val) |> Enum.map(fn c -> {c, :low} end) |> Map.new()}  end)
    |> IO.inspect()
  end

  def get_connections(parsed, val) do
    parsed
    |> Enum.filter(fn {v, {_, cons}} -> Enum.member?(cons, val) end)
    |> Enum.map(fn {v, {_, cons}} -> v end)
  end

  def get_type(str) do
    cond do
      str == "broadcaster" -> {:start, "broadcast"}
      String.starts_with?(str, "%") -> {:flipflop, String.slice(str, 1..-1)}
      String.starts_with?(str, "&") -> {:conjunction, String.slice(str, 1..-1)}
      true -> :error
    end
  end
end

Day20a.process("sample2.txt")

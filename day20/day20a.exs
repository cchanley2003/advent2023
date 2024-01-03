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

    ff_state = parsed
    |> Enum.filter(fn {_, {type, _}} -> type == :flipflop end)
    |> IO.inspect()
    |> Enum.map(fn {val, _} -> {val, :off} end)
    |> Map.new()
    |> IO.inspect()

    con_state = parsed
    |> Enum.filter(fn {_, {type, _}} -> type == :conjunction end)
    |> Enum.map(fn {val, {_, _}} -> {val, get_connections(parsed, val) |> Enum.map(fn c -> {c, :low} end) |> Map.new()}  end)
    |> Map.new()
    |> IO.inspect()

    start = hd(Enum.filter(parsed, fn {_, {type, _}} -> type == :start end))

    counts = %{:high => 0, :low => 1}

    # fire_pulses(parsed, start_pulses(parsed, start), {ff_state, con_state})
    run(parsed, {start_pulses(parsed, start), {ff_state, con_state}}, counts)
  end

  def run(_, {[], _}, counts) do
    Map.values(counts) |> Enum.sum()
  end
  def run(routes, {pulses, state}, counts) do
    {p, s, counts} = fire_pulses(routes, pulses, state, counts)
    |> IO.inspect()
    run(routes, {p, s}, counts)
  end

  def start_pulses(parsed, start) do
    {s, {_, connections}} = start
    pulses = connections
    |> IO.inspect()
    |> Enum.map(fn c -> {s, :low, c} end)
  end

  def fire_pulses(routes, pulses, states, counts) do
    dbg(pulses)
    Enum.reduce(pulses, {[], states, counts}, fn pulse, {l, sa, uc} ->
       {_, pt, _} = pulse
       uc = Map.update!(uc, pt, fn v -> v + 1 end)
       case fire_pulse(pulse, sa) do
        {{dest, pulse}, cs} ->
          if not(Map.has_key?(routes, dest)) do
            {l, cs, uc}
          else
            {_, conections} = Map.get(routes, dest)
            |> IO.inspect()
            res = conections
            |> Enum.map(fn c -> {dest, pulse, c} end)
            {l ++ res, cs, uc}
          end
        {nil, cs} -> {l, cs, uc}
       end
    end)
  end

  def fire_pulse({src, pulse_type, dest}, {ff_state, con_state} = states) do

    cond do
      Map.has_key?(ff_state, dest) -> handle_flipflop(pulse_type, dest, states)
      Map.has_key?(con_state, dest) -> handle_conjunction(pulse_type, dest, states)
      true -> {nil, states}
    end
  end

  def handle_flipflop(pulse_type, dest, {ff_state, con} = states) do
    if pulse_type == :high do
      {nil, states}
    else
      cur_state = Map.get(ff_state, dest)
      case cur_state do
        :off -> {{dest, :high}, {Map.put(ff_state, dest, :on), con}}
        :on -> {{dest, :low}, {Map.put(ff_state, dest, :off), con}}
      end
    end
  end

  def handle_conjunction(pulse_type, dest, {ff_state, con_state}) do
    updated = Map.put(con_state, dest, pulse_type)
    if Map.values(updated) |> Enum.all?(fn v -> v == :high end) do
      {{dest, :low}, {ff_state, updated}}
    else
      {{dest, :high}, {ff_state, updated}}
    end

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

Day20a.process("sample.txt")
|> IO.inspect()

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
    |> Enum.map(fn {val, _} -> {val, :off} end)
    |> Map.new()
    |> IO.inspect()

    con_state = parsed
    |> Enum.filter(fn {_, {type, _}} -> type == :conjunction end)
    |> Enum.map(fn {val, {_, _}} -> {val, get_connections(parsed, val) |> Enum.map(fn c -> {c, :low} end) |> Map.new()}  end)
    |> Map.new()
    |> IO.inspect()

    start = hd(Enum.filter(parsed, fn {_, {type, _}} -> type == :start end))

    counts = %{:high => 0, :low => 0}

    states = {ff_state, con_state}

    res = 1..1000
    |> Enum.reduce({counts, states}, fn _, {c, s} ->
      run(parsed, {start_pulses(parsed, start), s}, c)
    end)
    |> IO.inspect()

    {final_counts, _} = res
    dbg(final_counts[:high] * (final_counts[:low] + 1000))
    # fire_pulses(parsed, start_pulses(parsed, start), {ff_state, con_state})
    # run(parsed, {start_pulses(parsed, start), {ff_state, con_state}}, counts)
  end

  def run(_, {[],states}, counts) do
    {counts, states}
  end
  def run(routes, {pulses, state}, counts) do
    {p, s, counts} = fire_pulses(routes, pulses, state, counts)
    run(routes, {p, s}, counts)
  end

  def start_pulses(parsed, start) do
    {s, {_, connections}} = start
    pulses = connections
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
            res = conections
            |> Enum.map(fn c -> {dest, pulse, c} end)
            {res ++ l, cs, uc}
          end
        {nil, cs} -> {l, cs, uc}
       end
    end)
  end

  def fire_pulse({src, pulse_type, dest}, {ff_state, con_state} = states) do
    cond do
      Map.has_key?(ff_state, dest) -> handle_flipflop(pulse_type, dest, states)
      Map.has_key?(con_state, dest) -> handle_conjunction(pulse_type, src, dest, states)
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

  def handle_conjunction(pulse_type, src, dest, {ff_state, con_state}) do
    IO.puts("Handling conjunction")
    in_state = Map.get(con_state, dest) |> Map.put(src, pulse_type)
    updated = Map.put(con_state, dest, in_state)
    if Map.values(in_state) |> Enum.all?(fn v -> v == :high end) do
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

Day20a.process("real.txt")
|> IO.inspect()

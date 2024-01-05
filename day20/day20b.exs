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

    con_state = parsed
    |> Enum.filter(fn {_, {type, _}} -> type == :conjunction end)
    |> Enum.map(fn {val, {_, _}} -> {val, get_connections(parsed, val) |> Enum.map(fn c -> {c, :low} end) |> Map.new()}  end)
    |> Map.new()
    |> IO.inspect()

    start = hd(Enum.filter(parsed, fn {_, {type, _}} -> type == :start end))

    counts = %{:high => 0, :low => 0}

    cycle_states = parsed
    |> Enum.filter(fn {_, {_, cons}} -> Enum.member?(cons, "kh") end)
    |> Enum.map(fn {v, _} -> v end)

    dbg(cycle_states)

    sample = hd(cycle_states)

    run(parsed, {start_pulses(start), {ff_state, con_state}}, [])

    cycle_states
    |> Enum.map(fn s -> high_pulse_emitted(s, parsed, start_pulses(start), {ff_state, con_state}, 0) end)
    |> Enum.map(fn {c, _} -> c end)
    |> Enum.reduce(fn c, acc -> lcm(c, acc) end)

  end

  def lcm(a, b) do
    trunc(a * b / Integer.gcd(a, b))
  end

  def run(_, {[],states}, fired) do
    {fired, states}
  end
  def run(routes, {pulses, state}, fired) do
    {p, s} = fire_pulses(routes, pulses, state)
    run(routes, {p, s}, p ++ fired)
  end

  def high_pulse_emitted(module, routes, pulses, states, count) do
    {fired, ns} = run(routes, {pulses, states}, [])
    if Enum.any?(fired, fn {src, pt, _} -> src == module and pt == :high end) do
      {count + 1, ns}
    else
      high_pulse_emitted(module, routes, pulses, ns, count + 1)
    end
  end

  def start_pulses(start) do
    {s, {_, connections}} = start
    connections
    |> Enum.map(fn c -> {s, :low, c} end)
  end

  def fire_pulses(routes, pulses, states) do
    Enum.reduce(pulses, {[], states}, fn pulse, {l, sa} ->
       {_, pt, _} = pulse
       case fire_pulse(pulse, sa) do
        {{dest, pulse}, cs} ->
          if not(Map.has_key?(routes, dest)) do
            {l, cs}
          else
            {_, conections} = Map.get(routes, dest)
            res = conections
            |> Enum.map(fn c -> {dest, pulse, c} end)
            {res ++ l, cs}
          end
        {nil, cs} -> {l, cs}
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
    |> Enum.filter(fn {_, {_, cons}} -> Enum.member?(cons, val) end)
    |> Enum.map(fn {v, {_, _}} -> v end)
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

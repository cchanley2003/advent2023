Mix.install([:aja])

defmodule Day15 do
  import Aja
  alias Aja.Vector, as: Vec

  def process(line) do
    decoded = line
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&Day15.decode/1)

    count_vec = Vec.duplicate(0, 256)
    state_vec = Vec.duplicate(%{}, 256)

    {state_vec, count_vec} = Enum.reduce(decoded, {state_vec, count_vec}, fn state, {state_vec, count_vec} ->
      run_machine({state_vec, count_vec}, state)
    end)
    |> dbg()

    state_vec
    |> Enum.with_index()
    |> Enum.reject(fn {map, _} -> map_size(map) == 0 end)
    |> Enum.map(fn {map, index} ->
      map
      |> Map.to_list()
      |> Enum.sort(fn {_, {_, count1}}, {_, {_, count2}} -> count1 <= count2 end)
      |> Enum.map(fn {label, {value, count}} -> {label, value} end)
      |> Enum.with_index()
      |> Enum.map(fn { {label, value}, ii } -> (index + 1) * (ii + 1) * String.to_integer(value) end)
      |> Enum.sum()

    end)
    |> Enum.sum()
    |> IO.inspect()
  end
  def run_machine({state_vec, count_vec}, {label, box, action, value}) do
    case action do
      :add ->
        label_exists = Map.has_key?(state_vec[box], label)
        new_count = if label_exists, do: elem(state_vec[box][label], 1), else: count_vec[box] + 1
        updated_count_vec = if label_exists, do: count_vec, else: Vec.replace_at(count_vec, box, new_count)

        new_map = Map.put(state_vec[box], label, {value, new_count})
        updated_state_vec = Vec.replace_at(state_vec, box, new_map)

        {updated_state_vec, updated_count_vec}

      :drop ->
        updated_state_vec = Vec.update_at(state_vec, box, &Map.delete(&1, label))
        {updated_state_vec, count_vec}
    end
  end

  def decode(line) do
    if String.ends_with?(line, "-") do
      label = String.slice(line, 0..-2)
      {label, hash_string(label), :drop, nil}
    else
      parts = String.split(line, "=")
      label = List.first(parts)
      value = List.last(parts)
      {label, hash_string(label), :add, value}
    end
  end

  def hash_string(str) do
    str
    |> to_char_list()
    |> Enum.reduce(0, fn char, acc ->
      rem(((char + acc) * 17), 256)
    end)
  end
end

line = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"
# Day15.hash_string("HASH")
# |> IO.inspect()

Day15.process(File.read!("real.txt"))

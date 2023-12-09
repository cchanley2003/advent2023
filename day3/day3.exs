defmodule Day3 do
  def process_file(file_path) do
    matrix = File.stream!(file_path)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, index}, map ->
        Map.put(map, index, line)
      end)

    symbol_locations =
      matrix
      |> Enum.reduce(%{}, fn {index, line}, map ->
          Map.put(map, index, line
            |> String.graphemes()
            |> Enum.with_index()
            |> Enum.filter(fn {char, _} -> is_symbol(char) end)
            |> Enum.map(fn {_, col} -> col end)
          )
        end)


    candidates = matrix
    |> Enum.map(fn {index, line} ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.map(fn {char, col} ->
            is_number = char =~ ~r/^\d$/
            if is_number and is_candidate(symbol_locations, matrix, char, index, col) do
              {index, col, col}
            else
              nil
            end
          end)
        |> Enum.filter(fn x -> x != nil end)
        |> List.flatten()
      end)
    |> List.flatten()
    |> MapSet.new()

    # Okay merge all the canidates, extend them into full numbers, and sum
    candidates
      |> Enum.sort()
      |> IO.inspect()
      |> Enum.reduce([], &merge/2)
      |> IO.inspect()
      |> Enum.map(fn {row, col_start, col_end} ->
          line = matrix[row]
          s = find_start(line, col_start)
          e = find_end(line, col_end)
          String.slice(line, s..e)
        end)
      |> Enum.map(fn x -> String.to_integer(x) end)
      |> Enum.sum()
  end

  defp find_end(line, last) do
    if last + 1 < String.length(line) and String.at(line, last + 1) =~ ~r/^\d$/ do
      find_end(line, last + 1)
    else
      last
    end
  end
  defp find_start(line, start) do
    if start - 1 >= 0 and String.at(line, start - 1) =~ ~r/^\d$/ do
      find_start(line, start - 1)
    else
      start
    end
  end

  defp merge(candidate, []) do
    [candidate]
  end

  defp merge({row, col_start, col_end} = candidate, [{row, _, col_end_prev} = prev | rest] = acc)
       when col_end_prev + 1 >= col_start do
    [{row, elem(prev, 1), col_end} | rest]
  end

  defp merge(candidate, acc) do
    [candidate | acc]
  end

  defp is_candidate(symbol_locations, matrix, char, row, col) do
    symbol_locations
    |> Enum.map(fn {r, c_list} ->
      c_list
        |> Enum.map(fn c ->
         max(abs(row - r),  abs(col - c)) <= 1 end)
        |> Enum.reduce(false, fn x, acc -> x || acc end)
      end)
    |> Enum.reduce(false, fn x, acc -> x || acc end)

  end

  def is_symbol(char) do
    char =~ ~r/[^\w.\s]/
  end
end

res = Day3.process_file("sample.txt")
IO.puts(res)

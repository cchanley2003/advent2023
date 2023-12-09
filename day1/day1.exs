defmodule Day1 do
  def process_file(file_path) do
    File.stream!(file_path)
    |> Enum.reduce(0, fn line, acc ->
      line_sum = line
      |> process_line_part2()
      |> concat_tuple()
      |> String.to_integer()
      line_sum + acc
    end)
  end

  defp process_line_part1(line) do
    String.graphemes(line)
    |> Enum.reduce({nil, ""}, fn char, {first_pos, last_pos} ->
      cond do
        char =~ ~r/^\d$/ and first_pos == nil ->
          { char, char } # Found the first occurrence
        char =~ ~r/^\d$/ ->
          {first_pos, char} # Update the last occurrence
        true ->
          {first_pos, last_pos} # Keep the current state
      end
    end)
  end

  defp process_line_part2(line) do
    String.graphemes(line)
    |> Enum.with_index()
    |> Enum.reduce({nil, ""}, fn {char, index}, {first_pos, last_pos} ->
      conversion = match_start(String.slice(line, index..-1))
      cond do
        (char =~ ~r/^\d$/ or conversion != nil) and first_pos == nil ->
          { conversion || char, conversion || char} # Found the first occurrence
        char =~ ~r/^\d$/ or conversion != nil ->
          {first_pos, conversion || char} # Update the last occurrence
        true ->
          {first_pos, last_pos} # Keep the current state
      end
    end)
  end



  defp match_start(str) do
    substrings = [{"one", "1"}, {"two", "2"}, {"three", "3"}, {"four", "4"}, {"five", "5"}, {"six", "6"}, {"seven", "7"}, {"eight", "8"}, {"nine", "9"}]
    # Find the first tuple where the string starts with the first element of the tuple
    case Enum.find(substrings, fn {substr, _} -> String.starts_with?(str, substr) end) do
      nil ->
        nil  # Return nil if no match is found
      {_, value} ->
        value  # Return the second element of the tuple if a match is found
    end
  end

  defp concat_tuple({str1, str2}) do
    str1 <> str2
  end
end


res = Day1.process_file("day1Real.txt")

IO.puts(res)

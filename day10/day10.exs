defmodule Day10 do
  @east %{"-" => [{1, 0}, {2,0}], "J" => [{1, 0},{1, -1}], "7" => [{1, 0}, {1, 1}]}
  @west %{"-" => [{-1, 0}, {-2,0}], "L" => [{-1, 0},{-1, -1}], "F" => [{-1, 0}, {-1, 1}]}
  @north %{"|" => [{0, -1}, {0,-2}], "F" => [{0, -1}, {1, -1}], "7" => [{0, -1}, {-1, -1}]}
  @south %{"|" => [{0, 1}, {0,2}], "J" => [{0, 1}, {-1, 1}], "L" => [{0, 1}, {1, 1}]}

  # From the start get the 2 connections
  # For each connection, get the next connection
  # When we meet return count

  def process_file(path) do
    {map,start} =  File.stream!(path)
    |> Enum.with_index()
    |> Enum.reduce({%{}, nil}, fn {line, y}, all ->
        String.trim(line)
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(all, fn {char, x}, {map, start} ->
          map = Map.put(map, {x, y}, char)
          if char == "S"  do
             {map, {x, y}}
          else
              {map, start}
          end
        end)
      end)

    walk_map(map, start)
    |> dbg()
  end

  def find_next(map, {x, y}) do
    IO.inspect("Finding next for #{x}, #{y}")
    [ {{1, 0}, :east}, {{-1, 0}, :west}, {{0, -1}, :north}, {{0, 1}, :south }]
    |> Enum.map(fn {{xd, yd}, dir} ->
       {map[{x + xd, y + yd}], dir}
    end)
    |> dbg()
    |> Enum.filter(fn {char, _} -> char != nil and char != "." end)
    |> dbg()
    |> Enum.map(fn {char, dir} ->
       case dir do
        :east ->@east[char]
        :west -> @west[char]
        :north -> @north[char]
        :south -> @south[char]
      end
    end)
    |> dbg()
    |> Enum.filter(fn x -> x != nil end)
    |> Enum.map(&Enum.reverse/1)
    |> dbg()
    |> Enum.map(fn l ->
       Enum.map(l, fn {xd, yd} -> {x + xd, y + yd} end) end)
    |> dbg()
  end

  def walk_map(map, start) do
    walk_all(map, [[start]])
  end

  def walk_all(map, all_paths) do
    next_level = all_paths
    |> dbg()
    |> Enum.reduce([], fn [ top | _ ] = path, acc ->
      next = find_next(map, top)
      res = Enum.map(next, fn n -> n ++ path end)
      |> dbg()
      |> Enum.reject(fn [ next | tail] = re ->
        # Make sure we don't have a cycle
        Enum.any?(tail, fn x -> x == next end)
      end)
      |> dbg()
      res ++ acc
    end)
    |> dbg()

    matched = match_in_lists(next_level)
    if matched != nil do
      base = hd(next_level)
      |> Enum.drop(matched)
      |> length()
      base - 1
    else
      walk_all(map, next_level)
    end
  end

  def match_in_lists(lists) do
    # Ensure that all lists have at least two elements
    Enum.map(lists, fn l -> Enum.take(l, 2) end)
    |> Enum.zip()
    |> dbg()
    |> Enum.map(fn {l1, l2} -> l1 == l2 end)
    |> Enum.with_index()
    |> Enum.reduce(nil, fn {match, index}, acc ->
      if match do
        index
      else
        acc
      end
    end)
    |> dbg()
    # Get the first two elements of each list

    # Check for matches and return index if found

  end

end

# Day10.match_in_lists([[2, 5, 3], [3, 1, 4]])
# |> dbg()
Day10.process_file("sample.txt")

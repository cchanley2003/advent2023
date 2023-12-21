defmodule Day10 do
  @dir %{ {:south, "L"} => {1, 0}, {:south, "|"} => {0, 1}, {:east, "J"} => {0, -1}, {:north, "F"} => {1, 0},
           {:west, "-"} => {-1, 0}, {:north, "7"} => {-1, 0}, {:west, "L"} => {0, -1}, {:north, "|"} => {0, -1},
           {:east, "-"} => {1, 0}, {:west, "F"} => {0, 1}, {:south, "J"} => {-1, 0}, {:east, "7"} => {0, 1} }

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
    {x, y} = start
    steps = walk(map, [{x, y + 1}, {x , y}], start)
    path_map = steps
    |> Enum.reduce(%{}, fn {x, y}, acc ->
      Map.put(acc, {x, y}, true)
    end)
    calc_area(path_map, steps, %{}, 0)
    |> dbg()
  end

  def calc_area(map, [loc | []], checked, area) do
    area
  end

def calc_area(map, [loc, prev_loc | _] = steps, checked, area) do
  dir = calc_direction(prev_loc, loc)
  boundary = cond do
    dir == :north or dir == :south ->
      find_key_in_x_direction(map, loc, 1)
    dir == :east or dir == :west ->
      find_key_in_y_direction(map, loc, 1)
    true -> nil
  end
  dbg(checked)
  dbg(loc)
  dbg(dir)
  dbg(boundary)
  new_area = if checked[boundary] do
    0
  else
    {xb, yb} = boundary
    {x, y} = loc
    ((abs(xb - x) + abs(yb - y)) - 1)
  end
  new_checked = Map.put(checked, boundary, true)
  dbg(new_area)
  calc_area(map, tl(steps), Map.put(new_checked, loc, true), new_area + area)
end

def find_key_in_x_direction(map, {x, y}, step \\ 1) do
  keys_to_check = [{x + step, y}, {x - step, y}]

  case Enum.find(keys_to_check, fn key -> Map.has_key?(map, key) end) do
    nil -> find_key_in_x_direction(map, {x, y}, step + 1)
    found_key -> found_key
  end
end

def find_key_in_y_direction(map, {x, y}, step \\ 1) do
  keys_to_check = [{x, y + step}, {x, y - step}]
  dbg(keys_to_check)
  case Enum.find(keys_to_check, fn key -> Map.has_key?(map, key) end) do
    nil -> find_key_in_y_direction(map, {x, y}, step + 1)
    found_key -> found_key
  end
end

def walk(map, [cur_loc,  prev_loc | _] = steps, goal) do
  dir = calc_direction(prev_loc, cur_loc)
  char = map[cur_loc]
  new_loc = move(cur_loc, char, dir)
  if(new_loc == goal) do
    steps
  else
    walk(map, [new_loc | steps], goal)
  end

end

def move({x, y}, char, dir) do
  {xd, yd} = @dir[{dir, char}]
  {x + xd, y + yd}
end

  def calc_direction({x1, y1}, {x2, y2}) do
    # IO.puts("Calculating direction for #{x1}, #{y1} and #{x2}, #{y2}")
    x3 = x1 - x2
    y3 = y1 - y2
    case {x3, y3} do
    {0, 1} -> :north
    {0, -1} -> :south
    {1, 0} -> :west
    {-1, 0} -> :east
    end
  end
end
# Day10.match_in_lists([[2, 5, 3], [3, 1, 4]])
# |> dbg()
Day10.process_file("partSample.txt")
|> IO.inspect()

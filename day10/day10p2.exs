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

    # Map all the steps
    path_map = steps
    |> Enum.reduce(%{}, fn {x, y}, acc ->
      Map.put(acc, {x, y}, true)
    end)

    # Find the max x and y
    {max_x, max_y} = map
    |> Map.keys()
    |> Enum.reduce({0, 0}, fn {x, y}, {max_x, max_y} ->
      {max(max_x, x), max(max_y, y)}
    end)

    # Find inside boundary direction
    find_inside_direction(path_map, steps, {max_x, max_y})


  end

  def find_inside_direction(path_map, [cur, prev | rem], {max_x, max_y}) do
    dbg(cur)
    dbg(prev)
    dir = calc_direction(prev, cur)
    dbg(dir)
    inner_dir = case dir do
      :north ->
        find_inner_dir_in_x_direction(path_map, :north, cur, max_x)
      :south ->
        find_inner_dir_in_x_direction(path_map, :south, cur, max_x)
      :east ->
        find_inner_dir_in_y_direction(path_map, :east, cur, max_y)
      :west ->
        find_inner_dir_in_y_direction(path_map, :west, cur, max_y)
    end
    if inner_dir == nil do
      find_inside_direction(path_map, [prev | rem], {max_x, max_y})
    else
      inner_dir
    end
  end

  def find_inner_dir_in_y_direction(path_map, dir, cur, max_y) do
    find_inner_dir_in_y_direction(path_map, dir, cur, max_y, {nil, nil}, 1)
  end

  def find_inner_dir_in_y_direction(_, _, _, _, {lesser_path, greater_path}, _) when lesser_path != nil and greater_path != nil do
    nil
  end

  def find_inner_dir_in_y_direction(path_map, dir, {x, y} = loc, max_y, {lesser_path, greater_path}, step) do
    lesser_y = y - step
    greater_y = y + step

    intersections =
      cond do
        lesser_path == nil and greater_path == nil ->
          {path_map[{x, lesser_y}], path_map[{x, greater_y}]}
        lesser_path == nil ->
          {path_map[{x, lesser_y}], greater_path}
        greater_path == nil ->
          {lesser_path, path_map[{x, greater_y}]}
      end
    cond do
      lesser_y < 0 and dir == :east -> {loc, :north}
      lesser_y < 0 and dir == :west -> {loc, :south}
      greater_y > max_y and dir == :east -> {loc, :south}
      greater_y > max_y and dir == :west -> {loc, :north}
      true -> find_inner_dir_in_y_direction(path_map, dir, loc, max_y, intersections, step + 1)
    end
  end

  def find_inner_dir_in_x_direction(path_map, dir, cur, max_x) do
    find_inner_dir_in_x_direction(path_map, dir, cur, max_x, {nil, nil}, 1)
  end

  def find_inner_dir_in_x_direction(_, _, _, _, {lesser_path, greater_path}, _) when lesser_path != nil and greater_path != nil do
    nil
  end

  def find_inner_dir_in_x_direction(path_map, dir, {x, y} = cur, max_x, {lesser_path, greater_path}, step) do
    lesser_x = x - step
    greater_x = x + step

    intersections =
      cond do
        lesser_path == nil and greater_path == nil ->
          {path_map[{lesser_x, y}], path_map[{greater_x, y}]}
        lesser_path == nil ->
          {path_map[{lesser_x, y}], greater_path}
        greater_path == nil ->
          {lesser_path, path_map[{greater_x, y}]}
      end

    cond do
      lesser_x < 0 and dir == :north -> {cur, :west}
      lesser_x < 0 and dir == :south -> {cur, :east}
      greater_x > max_x and dir == :north -> {cur, :east}
      greater_x > max_x and dir == :south -> {cur, :west}
      true -> find_inner_dir_in_x_direction(path_map, dir, cur, max_x, intersections, step + 1)
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

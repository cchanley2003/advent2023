defmodule Day10 do
  @dir %{
    {:south, "L"} => {1, 0},
    {:south, "|"} => {0, 1},
    {:east, "J"} => {0, -1},
    {:north, "F"} => {1, 0},
    {:west, "-"} => {-1, 0},
    {:north, "7"} => {-1, 0},
    {:west, "L"} => {0, -1},
    {:north, "|"} => {0, -1},
    {:east, "-"} => {1, 0},
    {:west, "F"} => {0, 1},
    {:south, "J"} => {-1, 0},
    {:east, "7"} => {0, 1}
  }

  # From the start get the 2 connections
  # For each connection, get the next connection
  # When we meet return count

  def process_file(path) do
    {map, start} =
      File.stream!(path)
      |> Enum.with_index()
      |> Enum.reduce({%{}, nil}, fn {line, y}, all ->
        String.trim(line)
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(all, fn {char, x}, {map, start} ->
          map = Map.put(map, {x, y}, char)

          if char == "S" do
            {map, {x, y}}
          else
            {map, start}
          end
        end)
      end)

    {x, y} = start
    steps = walk(map, [{x, y + 1}, {x, y}], start)

    steps = [start | steps]

    map = Map.put(map, start, "F")

    # Map all the steps
    path_map =
      steps
      |> Enum.reduce(%{}, fn {x, y}, acc ->
        Map.put(acc, {x, y}, true)
      end)

    # Find the max x and y
    {max_x, max_y} =
      map
      |> Map.keys()
      |> Enum.reduce({0, 0}, fn {x, y}, {max_x, max_y} ->
        {max(max_x, x), max(max_y, y)}
      end)

    # actual_path = Enum.reverse(steps)
    # |> IO.inspect()
    shoot_rays(map, path_map, {max_x, max_y})
  end

  def shoot_rays(grid, path_map, {max_x, max_y}) do
    Map.keys(grid)
    |> Enum.reject(fn {x, y} -> Map.has_key?(path_map, {x, y}) end)
    |> Enum.reduce(0, fn {x, y}, a ->
      # IO.puts("Checking #{x}, #{y}")
      intersections = shoot_ray(grid, {x, y}, path_map, {max_x, max_y})
      # IO.puts("#{x}, #{y} has #{intersections}")

      if rem(intersections, 2) == 0 do
        a
      else
        a + 1
      end
    end)
  end

  def shoot_ray(grid, loc, path_map, maxes) do
    shoot_ray(grid, loc, path_map, maxes, 0)
  end

  def shoot_ray(grid, {x, y} = loc, path_map, {max_x, max_y}, intersects) do
    if(x > max_x or y > max_y) do
      intersects
    else
      char = grid[loc]
      # IO.puts("Char is #{char} at #{x}, #{y}")

      if char != "L" and char != "7" and Map.has_key?(path_map, {x, y}) do
        # IO.puts("We intersected")

        shoot_ray(
          grid,
          {x + 1, y + 1},
          path_map,
          {max_x, max_y},
          intersects + 1
        )
      else
        # IO.puts("We didn't intersect")

        shoot_ray(
          grid,
          {x + 1, y + 1},
          path_map,
          {max_x, max_y},
          intersects
        )
      end
    end
  end

  def walk(map, [cur_loc, prev_loc | _] = steps, goal) do
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
Day10.process_file("real.txt")
|> IO.inspect()

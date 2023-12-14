import Aja

vec([a, 2, c, _d, e]) = Aja.Vector.new(1..5); {a, c, e}

IO.puts(a + c + e)

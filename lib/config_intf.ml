module Root = struct
  type t =
    | Global
    | Local
end

module Config = struct
  type t = { root : Root.t }
end

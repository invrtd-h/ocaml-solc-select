open! Import

type t =
  { major : int
  ; minor : int
  ; patch : int
  }

let ( *~~ ) lbd ubd = List.init ~len:(ubd - lbd + 1) ~f:(( + ) lbd)
let mk major minor patch : t = { major; minor; patch }

let of_string s : t option =
  let l = String.split_on_char ~sep:'.' s in
  let l = List.map ~f:int_of_string_opt l in
  match l with
  | [ Some i; Some j; Some k ] -> Some { major = i; minor = j; patch = k }
  | _ -> None
;;

let of_string_exn s : t =
  match of_string s with
  | Some v -> v
  | None -> invalid_arg "Solc.Ver.of_string_exn : not in the format of i.j.k"
;;

let parse_default_version_string _s : t = failwith ""

(** human-readable version name. *)
let pp_human ppf v = Format.fprintf ppf "%i.%i.%i" v.major v.minor v.patch

(** human-readable to-string. *)
let to_string v = Printf.sprintf "%i.%i.%i" v.major v.minor v.patch

let get_major_minor solv = solv.major, solv.minor

let versions =
  let mk major minor patches = List.map ~f:(fun p -> mk major minor p) patches in
  mk 0 4 (10 *~~ 26)
  @ mk 0 5 (0 *~~ 17)
  @ mk 0 6 (0 *~~ 12)
  @ mk 0 7 (0 *~~ 6)
  @ mk 0 8 (0 *~~ 30)
;;

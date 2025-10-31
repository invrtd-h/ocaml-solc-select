
type t = { major : int; minor : int; patch : int }

let ( *~~ ) lbd ubd = List.init (ubd - lbd + 1) (( + ) lbd)
let mk major minor patch : t = { major; minor; patch }

let of_string s : t option =
  let l = String.split_on_char '.' s in
  let l = List.map int_of_string_opt l in
  match l with [ Some i; Some j; Some k ] -> Some { major = i; minor = j; patch = k } | _ -> None
;;

let of_string_exn s : t =
  match of_string s with
  | Some v -> v
  | None -> invalid_arg "Solc.Ver.of_string_exn : not in the format of i.j.k"
;;

let parse_default_version_string _s : t =
  failwith ""
;;

(** human-readable version name. *)
let pp_human ppf v = Format.fprintf ppf "%i.%i.%i" v.major v.minor v.patch

(** human-readable to-string. *)
let to_string v = Printf.sprintf "%i.%i.%i" v.major v.minor v.patch

let get_major_minor solv = (solv.major, solv.minor)

let versions =
  let mk major minor patches = List.map (fun p -> mk major minor p) patches in
  mk 0 4 (16 *~~ 26)
  (* 0.4.0~~11 do not support --ast-compact-json, 12~15 do not support stateMutability *)
  @ mk 0 5 (1 *~~ 17) (* there was a report that 0.5.0 --ast-compact-json produces an error *)
  @ mk 0 6 (0 *~~ 12)
  @ mk 0 7 (0 *~~ 6)
  @ mk 0 8 (0 *~~ 30)
;;

let least_supported = List.hd versions
let representatives = [ mk 0 4 16; mk 0 4 26; mk 0 5 17; mk 0 6 12; mk 0 7 6; mk 0 8 28 ]

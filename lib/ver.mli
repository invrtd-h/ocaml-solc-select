(** example: 0.4.22 -> [{ major = 0; minor = 4; patch = 22; }] *)
type t = { major : int; minor : int; patch : int }
[@@deriving compare, equal, show { with_path = false }]

val mk : int -> int -> int -> t

(** "x.y.z" to version type. *)
val of_string : string -> t option

(** "x.y.z" to version type. *)
val of_string_exn : string -> t

val parse_default_version_string : string -> t
val pp_human : Format.formatter -> t -> unit
val to_string : t -> string
val get_major_minor : t -> int * int
val versions : t list

(** = 0.4.16 *)
val least_supported : t

val representatives : t list

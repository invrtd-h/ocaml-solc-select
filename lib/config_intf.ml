module Root = struct
  type t =
    | Crytic (** [~/.solc-select] *)
    | Global (** [~/.osolc-select] *)
    | Local (** [$OPAM_SWITCH_PREFIX/sbin/osolc-select] *)
end

module type Install_config = sig
  val root : Root.t
  val forced : bool
  val command : string list
end

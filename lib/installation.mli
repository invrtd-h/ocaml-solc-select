open Config

val is_solc_installed : (module Install_config) -> Ver.t -> bool
val install_solc : (module Install_config) -> unit

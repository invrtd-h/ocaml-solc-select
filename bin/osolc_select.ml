open Climate

let install =
  let open Arg_parser in
  let+ versions = pos_all ~doc:"Solidity versions to install." string in
  let version =
    List.hd versions
    (* temp *)
  in
  Lib.Installation.install_solc version
;;

let cmd =
  let open Command in
  group
    [ subcommand "install" (Command.singleton ~doc:"Install solc binaries." install)
    ; subcommand "completions" print_completion_script_bash
    ]
;;

let () = Climate.Command.run cmd

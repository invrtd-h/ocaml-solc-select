open Climate

let help_style =
  let open Help_style in
  { program_doc = { ansi_style_plain with color = None }
  ; usage = { ansi_style_plain with color = None; bold = true }
  ; section_heading = { ansi_style_plain with color = None; bold = true }
  ; arg_name = { ansi_style_plain with color = None; bold = true }
  ; arg_doc = { ansi_style_plain with color = None }
  ; error = { ansi_style_plain with color = None }
  ; margin = Some 100
  }
;;

let install =
  let open Arg_parser in
  let+ versions = pos_all ~doc:"Solidity versions to install." string
  and+ forced = flag [ "f"; "forced" ] ~doc:"Forced install of solc."
  and+ global = flag [ "g"; "global" ] ~doc:"Solc is installed in $HOME/.osolc-select."
  and+ crytic =
    flag
      [ "c"; "crytic" ]
      ~doc:"Solc is installed in $HOME/.solc-select. '--global' is ignored."
  in
  let root =
    match crytic, global with
    | true, _ -> Lib.Config.Root.Crytic
    | _, true -> Global
    | _ -> Local
  in
  let module C = struct
    let forced = forced
    let root = root
    let command = versions
  end
  in
  Lib.Installation.install_solc (module C)
;;

let cmd =
  let open Command in
  group
    [ subcommand "install" (Command.singleton ~doc:"Install solc binaries." install)
    ; subcommand "completions" print_completion_script_bash
    ]
;;

let () = Climate.Command.run ~help_style cmd

open! Import

let cat l = List.reduce_exn ~f:Filename.concat l
let root_name = ".osolc-select"
let cat_fromroot l = cat (home :: root_name :: l)
let json_url = sprintf {|https://binaries.soliditylang.org/%s/list.json|} platform_name

(** [unzip dirpath base_filename]*)
let unzip dirpath base_filename =
  let zip_filename = cat [ dirpath; base_filename ] in
  let temp_filename = cat [ dirpath; "solc.exe" ] in
  let ic = Zip.open_in zip_filename in
  Zip.copy_entry_to_file ic (Zip.find_entry ic "solc.exe") temp_filename;
  Zip.close_in ic;
  Lwt_unix.rename temp_filename zip_filename
;;

let is_solc_installed (v : Ver.t) : bool =
  let vstring = Ver.to_string v in
  let expected_filepath = cat_fromroot [ ".solc"; vstring ] in
  if Sys.file_exists expected_filepath && Sys.is_regular_file expected_filepath
  then true (* todo: check commands exists well *)
  else false
;;

let http_get url =
  let open Lwt.Syntax in
  let* resp, body = Cohttp_lwt_unix.Client.get (Uri.of_string url) in
  let code = resp |> Cohttp.Response.status |> Cohttp.Code.code_of_status in
  if Cohttp.Code.is_success code
  then
    let* b = Cohttp_lwt.Body.to_string body in
    Lwt.return (Ok b)
  else Lwt.return (Error (Cohttp.Code.reason_phrase_of_code code))
;;

let solc_download (v : Ver.t) : unit Lwt.t =
  let module J = Yojson.Basic.Util in
  let open Lwt.Syntax in
  let member mem json : Yojson.Basic.t Lwt.t =
    let v = J.member mem json in
    match v with
    | `Null -> ksprintf invalid_arg "json member not found : %s" mem
    | _ -> Lwt.return v
  in
  let* got = http_get json_url in
  let json_content =
    match got with
    | Ok s -> s
    | Error e -> ksprintf invalid_arg "%s" e
  in
  let json =
    try Yojson.Basic.from_string json_content with
    | Yojson.Json_error _errmsg -> invalid_arg "json parsing failed"
  in
  let* json_releases = member "releases" json in
  let* json_builds =
    match J.member "builds" json with
    | `List l -> Lwt.return l
    | _ -> invalid_arg "The server gave us an unexpected json format"
  in
  let version_string = Ver.to_string v in
  let meta =
    List.find_opt json_builds ~f:(fun j ->
      let version' = J.member "version" j in
      J.to_string_option version' = Some version_string)
  in
  let* meta =
    match meta with
    | Some meta -> Lwt.return meta
    | None ->
      invalid_arg "maybe unsupported version by binaries.solidity.org. Version: %a"
  in
  let* sha256 = member "sha256" meta in
  let* sha256_expect =
    match sha256 with
    | `String s -> Lwt.return s
    | _ -> failwith "The server gave us an unexpected json format"
  in
  let* version_addr =
    match J.member version_string json_releases with
    | `String s -> Lwt.return s
    | _ -> failwith "maybe unsupported version by binaries.solidity.org"
  in
  ignore version_addr;
  let proc_url =
    sprintf {|https://binaries.soliditylang.org/%s/%s|} platform_name version_addr
  in
  let* got = http_get proc_url in
  let byte =
    match got with
    | Ok s -> s
    | Error e -> ksprintf failwith "%s" e
  in
  let hash = Digestif.SHA256.digest_string byte in
  let hash = Format.asprintf "%a" Digestif.SHA256.pp hash in
  let hash = "0x" ^ hash in
  let* () =
    if hash = sha256_expect then Lwt.return () else invalid_arg "Checksums do not match"
  in
  let filename =
    cat_fromroot [ "artifacts"; "solc-" ^ version_string; "solc-" ^ version_string ]
  in
  let dirname = Filename.dirname filename in
  makedirs ~exist_ok:true dirname;
  Out_channel.with_open_bin filename (fun oc -> Out_channel.output_string oc byte);
  let* () =
    (* if the file is zipped, unzip *)
    if String.ends_with ~suffix:".zip" proc_url
    then
      unzip
        (cat_fromroot [ "artifacts"; "solc-" ^ version_string ])
        ("solc-" ^ version_string)
    else Lwt.return ()
  in
  Unix.chmod filename 0o775;
  Lwt.return ()
;;

let install_solc_unit ?(forced = false) (ver : Ver.t) : unit Lwt.t =
  if (not forced) && is_solc_installed ver
  then failwith "Solc already installed : %a"
  else solc_download ver
;;

let install_solc ?(forced = false) (cmd : string) : unit =
  match cmd with
  | _ when Option.is_some (Ver.of_string cmd) ->
    Lwt_main.run @@ install_solc_unit ~forced (Ver.of_string_exn cmd)
  | "all" ->
    let open Lwt.Syntax in
    let vers = Ver.versions in
    let install_solc_unit cmd =
      try install_solc_unit ~forced cmd with
      | Failure s ->
        let* () = Lwt_io.printlf "A thread raised an error: Failure(%s)" s in
        let* () = Lwt_io.(flush stdout) in
        Lwt.return ()
      | Invalid_argument s ->
        let* () = Lwt_io.printlf "A thread raised an error: Invalid_argument(%s)" s in
        let* () = Lwt_io.(flush stdout) in
        Lwt.return ()
      | _ -> Lwt.return ()
    in
    let results = Lwt_list.map_p install_solc_unit vers in
    ignore @@ Lwt_main.run results
  | _ -> failwith "Unsupported cmd"
;;

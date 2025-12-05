include StdLabels
include MoreLabels

module List = struct
  include List

  let reduce ~f l =
    match l with
    | [] -> None
    | hd :: tl -> Some (List.fold_left ~f ~init:hd tl)
  ;;

  let reduce_exn ~f l = Option.get (reduce ~f l)
end

(** we support these three operating systems *)
let process ?(autotrim = false) cmd =
  let open Lwt.Syntax in
  let s =
    Lwt_process.with_process_full
      ("", Array.of_list cmd)
      (fun process ->
         let* out = Lwt_io.read process#stdout in
         let* err = Lwt_io.read process#stderr in
         let out, err = if autotrim then String.trim out, String.trim err else out, err in
         let* stat = process#status in
         Lwt.return (out, err, stat))
  in
  Lwt_main.run s
;;

module Os_type = struct
  type t =
    | Linux
    | MacOS
    | Windows
  [@@deriving show { with_path = false }, compare, equal]

  let get () : t =
    match Sys.os_type with
    | "Unix" ->
      (match process ~autotrim:true [ "uname" ] with
       | "Darwin", _, WEXITED 0 -> MacOS
       | _ -> Linux)
    | "Win32" | "Cygwin" -> Windows
    | _ -> failwith "Only Linux | MacOS | Windows are supported"
  ;;
end

let rec makedirs ?(exist_ok = true) ?(perm = 0o755) path =
  let parent_path = Filename.dirname path in
  if not (String.equal parent_path path) then makedirs parent_path ~exist_ok ~perm;
  try Unix.mkdir path perm with
  | Unix.Unix_error (Unix.EEXIST, "mkdir", _) ->
    if Unix.((stat path).st_kind <> S_DIR)
    then failwith (Printf.sprintf "Path %s exists but is not a directory" path)
    else if not exist_ok
    then failwith (Printf.sprintf "Path %s exists" path)
    else ()
  | Unix.Unix_error (Unix.ENOENT, "mkdir", _) ->
    failwith
      (Printf.sprintf "Could not create directory %s: Root directory is unreachable" path)
  | e -> raise e
;;

let platform_name =
  let platform = Os_type.get () in
  match platform with
  | Linux -> "linux-amd64"
  | MacOS -> "macosx-amd64"
  | Windows -> "windows-amd64"
;;

let home =
  try Unix.getenv "HOME" with
  | Not_found -> Unix.(getpwnam "username").pw_dir
;;

let sprintf = Printf.sprintf
let ksprintf = Printf.ksprintf
let failwithf fmt = ksprintf failwith fmt

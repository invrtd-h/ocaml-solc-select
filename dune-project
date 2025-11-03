(lang dune 3.17)

(name osolc-select)

(maintainers "invrtd-h")

(generate_opam_files true)

(license LICENSE)

(package
 (name osolc-select)
 (synopsis "solc-select, ocaml native")
 (description "solc-select, ocaml native")
 (depends 
  (ocaml (>= 5.1.1))
  dune
  camlzip
  (climate (>= 0.8.2)) ; modern CLI parser
  cohttp-lwt-unix
  digestif
  lwt
  (yojson (>= 2.2.2))))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project

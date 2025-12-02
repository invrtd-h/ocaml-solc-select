(lang dune 3.17)

(name osolc-select)

(authors "invrtd-h")

(maintainers "invrtd-h")

(generate_opam_files true)

(license MIT)

(homepage https://github.com/invrtd-h/ocaml-solc-select)

(bug_reports https://github.com/invrtd-h/ocaml-solc-select)

(package
 (name osolc-select)
 (synopsis "Solc-select, ocaml native")
 (description "Solc-select, ocaml native")
 (depends 
  (ocaml (>= 5.1.1))
  dune
  camlzip
  (climate (>= 0.9.0)) ; modern CLI parser
  cohttp-lwt-unix
  digestif
  (yojson (>= 2.2.2))))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project

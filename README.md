# ocaml-solc-select

```bash
> osolc-select --help
Usage: osolc-select [COMMAND]
       osolc-select [OPTION]…

Options:
  -h, --help  Show this help message.

Commands:
  install      Install solc binaries.
  completions  Print the bash completion script for this program.
  
-----

> osolc-select install --help
Install solc binaries.

Usage: osolc-select install [OPTION]… [STRING]…

Arguments:
  [STRING]...  Solidity versions to install.

Options:
  -f, --forced  Forced install of solc.
  -g, --global  Solc is installed in $HOME/.osolc-select.
  -c, --crytic  Solc is installed in $HOME/.solc-select. '--global' is ignored.
  -h, --help    Show this help message.
```
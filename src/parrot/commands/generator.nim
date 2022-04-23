# State of the Art 👌 JSON Content Rules Language,
# HTTP Server, Validator and Generator
#
# (c) 2022 Parrot is released under GPLv3 License
#          Made by Humans from OpenPeep
#          
#          https://parrot.codes
#          https://github.com/openpeep/parrot

import klymene/cli
from klymene import Value, `$`

proc runCommand*(rules, output: Value) =
    ## Command for generating binary JSON
    ## rules representation of given Parrot rules.
    
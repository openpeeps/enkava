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

import ../core/language/parser
import ../core/utils

proc runCommand*(input, rules: Value) =
    ## Command for validating a JSON file based on given rules
    # var p = parseProgram(getFileContents($rules), getFileContents($input))
    # if p.hasError():
    #     echo p.getError()
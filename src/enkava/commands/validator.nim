# State of the Art 👌 Validation Schema Language
# 
# Enkava is a top-notch language for validating JSON contents
# without dealing with JSON syntax at all.
# 
# Enkava has a RESTful API so it can be used with any HTTP library
# in any programming lanugage.
#
# (c) 2022 Enkava is released under GPLv3 License
#          Made by Humans from OpenPeep
#          
#          https://enkava.co
#          https://github.com/enkava

import klymene/cli
from klymene import Value, `$`

import ../core/language/parser
import ../utils

proc runCommand*(input, rules: Value) =
    ## Command for validating a JSON file based on given rules
    # var p = parseProgram(getFileContents($rules), getFileContents($input))
    # if p.hasError():
    #     echo p.getError()

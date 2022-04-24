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
import ../core/language/parser
from klymene import Value, `$`

import std/json
from std/os import getCurrentDir

proc runCommand*() =
    ## Command for generating binary JSON (BSON) rules for all rules
    let enkavaSampleFile = getCurrentDir() & "/hello.eka"
    var p = parseProgram(enkavaSampleFile)
    if p.hasError():
        display(p.getError(), indent = 2, br = "before")
        display(enkavaSampleFile, indent = 2, br = "after")
        quit()

    echo p.getStatements()
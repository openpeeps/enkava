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
import ../core/server/memory
from ../utils import writeBson, readBson

from times import cpuTime
from std/os import getCurrentDir
from std/strutils import formatFloat, ffDecimal
from klymene import Value, `$`

proc runCommand*() =
    ## Command for generating binary JSON (BSON) rules for all rules
    let enkavaSampleFile = getCurrentDir() & "/hello.eka"
    var p = parseProgram(enkavaSampleFile)

    if p.hasError():
        # Output Enkava syntax errors (if any)
        display(p.getError(), indent = 2, br = "before")
        display(enkavaSampleFile, indent = 2, br = "after")
        quit()
    
    # Save BSON representation for each Enkava rules
    let time = cpuTime()
    # let eka_path = getCurrentDir() & "/test.bson"
    # let bson_path = getCurrentDir() & "/test.bson"

    # writeBson(p.getStatements())
    # Memory.add("test", eka_path, bson_path)

    # echo readBson(getCurrentDir() & "/test.bson")
    
    let benchTime = (cpuTime() - time).formatFloat(format = ffDecimal, precision = 3)
    display("✨ Done in " & $benchTime & " seconds", indent=2, br="before")
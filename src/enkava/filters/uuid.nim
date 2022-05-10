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

from std/strutils import split, count, isAlphaAscii, toLowerAscii, Digits

proc isValid*(input: string, version = 0): bool =
    ## Validate given input string as UUID.
    ## This procedure covers all UUID versions.
    ## https://en.wikipedia.org/wiki/Universally_unique_identifier
    if input.count("-") != 4: return false

    var timeLow, timeMid, timeHigh, clockSeq, node: string
    (timeLow, timeMid, timeHigh, clockSeq, node) = input.toLowerAscii.split("-")

    if timeLow.len != 8 or timeMid.len != 4 or timeHigh.len != 4 or
       clockSeq.len != 4 or node.len != 12: return false
    
    # if timeHigh[0] == '1': version 1
    # elif timeHigh[0] == '2': version 2

    var alphaRange = {'a'..'f'}
    for column in [timeLow, timeMid, timeHigh, clockSeq, node]:
        for ichar in column:
            if ichar.isAlphaAscii:
                if ichar notin alphaRange:
                    return false
            else:
                if ichar notin Digits: return false

    result = true
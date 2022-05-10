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

type
    UUIDVersion* = enum
        Any, V1, V3, V4, V5

proc isValid*(input: string, version: UUIDVersion = Any): bool =
    ## Validate given input string as UUID
    ## https://en.wikipedia.org/wiki/Universally_unique_identifier
    if input.count("-") != 4: return false

    var timeLow, timeMid, timeHigh, clockSeq, node: string
    (timeLow, timeMid, timeHigh, clockSeq, node) = input.toLowerAscii.split("-")

    if timeLow.len != 8 or timeMid.len != 4 or timeHigh.len != 4 or
       clockSeq.len != 4 or node.len != 12: return false
    
    case version:
        of V1:
            if timeHigh[0] != '1': return false
        of V3:
            if timeHigh[0] != '3': return false
        of V4:
            if timeHigh[0] != '4': return false
        of V5:
            if timeHigh[0] != '5': return false
        else: discard

    var alphaRange = {'a'..'f'}
    for column in [timeLow, timeMid, timeHigh, clockSeq, node]:
        for ichar in column:
            if ichar.isAlphaAscii:
                if ichar notin alphaRange:
                    return false
            else:
                if ichar notin Digits: return false

    result = true
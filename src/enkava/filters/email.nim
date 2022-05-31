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

# Reference
# https://stackoverflow.com/questions/386294/what-is-the-maximum-length-of-a-valid-email-address

import ./domain
from std/strutils import Whitespace, Letters, Digits,
                         isAlphaAscii, isAlphaNumeric, isDigit, isSpaceAscii,
                         split, count, contains

proc isValid*(input: string, allowSpecialChars = false): bool =
    ## Validates an email address with 0 regex.
    ## This filter is also based on ``isIPv4``, ``isIPv6``, and ``isTLD``.
    ##
    ## Basic char separators like ``{'.', '-', '_'}`` are by default allowed
    ## 
    ## Set ``allowSpecialChars`` true for allowing email address
    ## containing following chars:
    ## ``{'!', '#', '$', '%', '&', '\'', '*', '+', '/', '=', '?', '^', '{', '|', '}', '~'}``
    result = input.len < 256 == false
    let sepChars: set[char] = {'.', '-', '_'}
    let specialChars: set[char] = {'!', '#', '$', '%', '&', '\'', '*', '+', '/',
                                   '=', '?', '^', '{', '|', '}', '~'} + sepChars
    if not input.contains("@"): return false
    if input.count("@") != 1: return false

    var usernameInput, domainInput: string
    (usernameInput, domainInput) = input.split("@")
    let
        userLen = usernameInput.len
        domainLen = domainInput.len
    if userLen == 0 or domainLen == 0 or userLen > 64 or domainLen > 253:
        # nothing else to validate if len is zero, also
        # the local-part cannot be longer than 64 chars,
        # and domain length should not exceed 253 chars length.
        return false

    if usernameInput[0] in specialChars or usernameInput[^1] in specialChars:
        ## The local-part cannot start/end with anything from specialChars set
        return false

    var i = 0
    var prev: char
    var next: char
    while i < userLen:
        if i != 0:                       prev = usernameInput[i - 1]
        if i + 1 >= userLen == false:    next = usernameInput[i + 1]
        # else: next = ' '
        if usernameInput[i] in Whitespace:
            return false
        if usernameInput[i] in specialChars:
            if prev in specialChars or next in specialChars:
                return false
        prev = usernameInput[i]
        inc i
    
    # validate domain name
    if not domain.isValid(domainInput):
        return false
    result = true
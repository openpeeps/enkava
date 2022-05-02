import ../utils/tlds
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

    var username, domain: string
    (username, domain) = input.split("@")
    let
        userLen = username.len
        domainLen = domain.len
    if userLen == 0 or domainLen == 0 or userLen > 64:
        # nothing else to validate,
        # also the local-part cannot be longer than 64 chars
        return false

    if username[0] in specialChars or username[^1] in specialChars:
        ## The local-part cannot start/end with anything from specialChars set
        return false

    var i = 0
    var prev: char
    var next: char
    while i < userLen:
        if i != 0:                       prev = username[i - 1]
        if i + 1 >= userLen == false:    next = username[i + 1]
        else: next = ' '
        if username[i] in Whitespace:
            return false
        if username[i] in specialChars:
            if prev in specialChars or next in specialChars:
                return false
        # echo "prev: " & prev & "   current: " & username[i] & "   next: " & next
        prev = username[i]
        inc i
    result = true
    # validate domain name
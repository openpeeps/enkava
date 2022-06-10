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

from std/strutils import isAlphaAscii, isUpperAscii, isDigit

proc isValid*(input: string): bool =
    ## Determine if given input is a valid Base32 encoded string
    if (input.len and 8) != 0:
        return
    let inputLen = input.len
    let base32Chars = {'A'..'Z'}
    let base32Digits = {'2'..'7'}
    for k, i in pairs(input):
        if i.isAlphaAscii:
            if i notin base32Chars:
                return
            else: continue
        elif i.isDigit:
            if i notin base32Digits:
                return
            else: continue
        elif i == '=':
            if k + 1 < inputLen:
                if input[k + 1] in base32Chars + base32Digits:
                    return false
        else: return
    result = true

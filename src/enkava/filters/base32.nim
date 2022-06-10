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
    let base32Chars = {'A'..'Z'}
    let base32Digits = {'2'..'7'}
    for i in input:
        if i.isAlphaAscii:
            if i notin base32Chars:
                return
            else: continue
        elif i.isDigit:
            if i notin base32Digits:
                return
            else: continue
        else: return
    result = true

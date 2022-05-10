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

import ../utils/tlds
from std/strutils import toUpperAscii, split, count

const validTLDs = GetTLDs

proc isValid*(input: string): bool =
    ## Validates a domain name including Top-Level-Domain.
    if input.count(".") == 0:
        return false
    var
        i = 0
        domainName: string
        tld: string
    
    if input.count(".") != 1: return false
    (domainName, tld) = input.split(".")

    let
        hyphenSep = {'-'}
        domainLen = domainName.len

    # a domain name cannot start/end with hyphen
    if input[0] in hyphenSep or input[^1] in hyphenSep: return false 
    # accept only valid Top Level Domains
    if toUpperAscii(tld) notin validTLDs: return false

    # while i < domainLen:
    #     inc i
    result = true
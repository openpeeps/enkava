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

import std/re
import std/strformat

proc isIPv4*(input: string): bool =
    let v4Segment = "(?:[0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])"
    let v4Address = "(" & v4Segment & "[.]){3}" & v4Segment
    result = re.match(input, re("^" & v4Address & "$"))

proc isIPv6*(input: string): bool =
    {.warning: "work in progress".}
    discard

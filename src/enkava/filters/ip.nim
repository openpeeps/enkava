# State of the Art 👌
# JSON Content Rules Validator Language with built-in REST API
#
# (c) 2022 Parrot is released under GPLv3 License
#          Made by Humans from OpenPeep
#          
#          https://parrot.codes
#          https://github.com/openpeep/parrot

import std/re
import std/strformat

proc isIPv4*(input: string): bool =
    let v4Segment = "(?:[0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])"
    let v4Address = "(" & v4Segment & "[.]){3}" & v4Segment
    result = re.match(input, re("^" & v4Address & "$"))

proc isIPv6*(input: string): bool =
    {.warning: "work in progress".}
    discard

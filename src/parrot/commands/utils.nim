# State of the Art 👌 JSON Content Rules Language,
# HTTP Server, Validator and Generator
#
# (c) 2022 Parrot is released under GPLv3 License
#          Made by Humans from OpenPeep
#          
#          https://parrot.codes
#          https://github.com/openpeep/parrot

from std/os import getCurrentDir, fileExists
from std/strutils import `%`, join

export join, `%`

const configFileName* = "parrot.config.yml"

proc getCurrentDirPath*(append: varargs[string]): string =
    ## Return the current directory path appended by given strings
    let currdir = getCurrentDir()
    result = if append.len == 0: currdir else: currdir & "/" & append.join("/")

proc configFileExists*(): bool =
    ## Determine if current directory contains a ``parrot.config.yml``
    result = fileExists(getCurrentDirPath(configFileName))
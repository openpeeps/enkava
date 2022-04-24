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

from std/os import getCurrentDir, fileExists
from std/strutils import `%`, join
from klymene/cli import display

export join, `%`

const configFileName* = "enkava.config.yml"

proc getCurrentDirPath*(append: varargs[string]): string =
    ## Return the current directory path appended by given strings
    let currdir = getCurrentDir()
    result = if append.len == 0: currdir else: currdir & "/" & append.join("/")

proc configFileExists*(): bool =
    ## Determine if current directory contains a ``parrot.config.yml``
    result = fileExists(getCurrentDirPath(configFileName))

proc readConfigContents*(configPath = ""): string = 
    ## Retrieve configuration contents from ``parrot.config.yml``
    let filePath = if configPath.len == 0: getCurrentDirPath(configFileName) else: configPath 
    try:
        result = readFile(filePath)
    except:
        display("Could not find a `$1` at\n  $2" % [configFileName, filePath], indent=2)
        quit()
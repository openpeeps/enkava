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

import bson
from std/os import getCurrentDir, fileExists, normalizePath, dirExists
from std/strutils import `%`, join
from klymene/cli import display

export join, `%`, normalizePath, dirExists

const configFileName* = "enkava.config.yml"

type
    EnkavaException* = CatchableError

proc writeBson*(ekaStatements, bsonPath: string) =
    ## Write current JSON AST to BSON
    var eka = newBsonDocument()
    eka["ast"] = ekaStatements
    writeFile(bsonPath, eka.bytes)

proc readBson*(ekaPath: string): string =
    ## Read current BSON and parse to JSON
    var eka: Bson = newBsonDocument(readFile(ekaPath))
    result = eka["ast"]

proc getCurrentDirPath*(append: varargs[string]): string =
    ## Return the current directory path appended by given strings
    let currdir = getCurrentDir()
    result = if append.len == 0: currdir else: currdir & "/" & append.join("/")

proc getDirPath*(append: varargs[string]): string =
    ## Normalize and returns the absolute path
    var path = getCurrentDirPath(append)
    path.normalizePath
    result = path

proc configFileExists*(): bool =
    ## Determine if current directory contains a ``enkava.config.yml``
    result = fileExists(getCurrentDirPath(configFileName))

proc readConfigContents*(configPath = ""): string = 
    ## Retrieve configuration contents from ``enkava.config.yml``
    let filePath = if configPath.len == 0: getCurrentDirPath(configFileName) else: configPath 
    try:
        result = readFile(filePath)
    except:
        display("Could not find a `$1` at\n  $2" % [configFileName, filePath], indent=2)
        quit()
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

import std/json
import klymene/cli, supranim

from klymene import Value, `$`, isNil
from std/strutils import join, `%`

init(App, autoIncludeRoutes = false)
include ../core/server/routes

import ../core/server/memory
import ../utils

proc runCommand*(configPath: Value) =
    ## Command for starting the HTTP server.
    if not configFileExists():
        display("👉 `$1` is missing. Run `enkava init` to generate your config." % [configFileName], indent=2)
        quit()
    let getConfigPath = if configPath.isNil(): "" else: $configPath

    # app = init(inlineConfigStr = readConfigContents(getConfigPath))
    var
        srcDirPath = getDirPath("../example/rules")
        outputDirPath = getDirPath("../example/bson")
        dirErrors: seq[string]
    
    for enkavaDir in [srcDirPath, outputDirPath]:
        if not dirExists(enkavaDir):
            dirErrors.add(enkavaDir)
    
    if dirErrors.len != 0:
        display("Missing directories:\n$1" % [join(dirErrors, "\n")], br="after")
        quit()

    # Indexing all ``.bson`` files based on given ``outputDirPath``
    # Binary JSON files are stored in a `MemoryTable` while Enkava server is running
    Memory.indexing(outputDirPath)

    # Start REST API microservice
    App.start()
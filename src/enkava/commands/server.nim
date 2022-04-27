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
import supranim, klymene/cli
from klymene import Value, `$`, isNil
from std/strutils import join, `%`

include ../core/server/routes
import ../core/server/memory
import ../utils

proc runCommand*(configPath: Value) =
    ## Command for starting a Enkava HTTP server powered by Supranim.
    ##
    ## In production mode is recommended to boot your Enkava instance(s)
    ## by passing an absolute path that points to your specific ``enkava.config.yml``.
    ## 
    ## Also, you may want to boot Enkava as a daemon via
    ## ``systemd`` or a similar daemon manager.
    if not configFileExists():
        display("👉 `$1` is missing. Run `enkava init` to generate your config." % [configFileName], indent=2)
        quit()
    let getConfigPath = if configPath.isNil(): "" else: $configPath
    var
        app = supranim.init(inlineConfigStr = readConfigContents(getConfigPath))
        srcDirPath = getDirPath(app.getConfig("app.source").getStr)
        outputDirPath = getDirPath(app.getConfig("app.output").getStr)
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
    app.start()